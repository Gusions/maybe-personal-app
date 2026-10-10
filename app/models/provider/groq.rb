# Provider per Groq, usato come alternativa gratuita a OpenAI/Gemini per le funzionalità AI
# (chat assistente, auto-categorizzazione, rilevamento esercenti).
#
# Groq espone un endpoint compatibile con le API OpenAI (Chat Completions), quindi riutilizziamo
# la gemma `ruby-openai` già presente, puntandola a un `uri_base` diverso. Il piano gratuito di
# Groq ha limiti giornalieri molto più alti di quello di Gemini.
#
# Stessa differenza rispetto a OpenAI già vista in Provider::Gemini: qui usiamo le "Chat
# Completions" stateless, quindi ricostruiamo l'intera cronologia (`previous_messages`) ad ogni
# chiamata.
class Provider::Groq < Provider
  include LlmConcept

  Error = Class.new(Provider::Error)

  BASE_URL = "https://api.groq.com/openai/v1/"

  MODELS = %w[llama-3.3-70b-versatile]
  AUTO_TASK_MODEL = "llama-3.3-70b-versatile"

  # Come per Gemini: 429 (rate limit) o 503 (sovraccarico) sono errori transitori.
  RETRYABLE_STATUSES = [ 429, 503 ].freeze

  def self.with_retry(max_attempts: 3)
    attempts = 0
    begin
      yield
    rescue Faraday::Error => e
      attempts += 1
      status = e.respond_to?(:response) ? e.response&.dig(:status) : nil

      if RETRYABLE_STATUSES.include?(status) && attempts < max_attempts
        sleep(2**attempts)
        retry
      else
        raise
      end
    end
  end

  def initialize(api_key)
    @client = ::OpenAI::Client.new(
      access_token: api_key,
      uri_base: BASE_URL,
      api_version: ""
    )
  end

  def supports_model?(model)
    MODELS.include?(model)
  end

  def auto_categorize(transactions: [], user_categories: [])
    with_provider_response do
      raise Error, "Too many transactions to auto-categorize. Max is 25 per request." if transactions.size > 25

      AutoCategorizer.new(
        client,
        transactions: transactions,
        user_categories: user_categories
      ).auto_categorize
    end
  end

  def auto_detect_merchants(transactions: [], user_merchants: [])
    with_provider_response do
      raise Error, "Too many transactions to auto-detect merchants. Max is 25 per request." if transactions.size > 25

      AutoMerchantDetector.new(
        client,
        transactions: transactions,
        user_merchants: user_merchants
      ).auto_detect_merchants
    end
  end

  def chat_response(prompt, model:, instructions: nil, functions: [], function_results: [], function_requests: [], previous_messages: [], streamer: nil, previous_response_id: nil)
    with_provider_response do
      messages = build_messages(
        prompt: prompt,
        instructions: instructions,
        previous_messages: previous_messages,
        function_requests: function_requests,
        function_results: function_results
      )

      tools = build_tools(functions)

      if streamer.present?
        accumulator = StreamAccumulator.new

        self.class.with_retry do
          client.chat(parameters: {
            model: model,
            messages: messages,
            tools: tools.presence,
            stream: proc do |chunk, _bytes|
              accumulator.add(chunk)

              if (text = accumulator.consume_new_text!)
                streamer.call(Provider::LlmConcept::ChatStreamChunk.new(type: "output_text", data: text))
              end
            end
          })
        end

        response = accumulator.to_chat_response
        streamer.call(Provider::LlmConcept::ChatStreamChunk.new(type: "response", data: response))
        response
      else
        raw_response = self.class.with_retry do
          client.chat(parameters: {
            model: model,
            messages: messages,
            tools: tools.presence
          })
        end

        parse_response(raw_response)
      end
    end
  end

  private
    attr_reader :client

    def build_tools(functions)
      functions.map do |fn|
        {
          type: "function",
          function: {
            name: fn[:name],
            description: fn[:description],
            parameters: fn[:params_schema]
          }
        }
      end
    end

    def build_messages(prompt:, instructions:, previous_messages:, function_requests:, function_results:)
      messages = []
      messages << { role: "system", content: instructions } if instructions.present?
      messages.concat(previous_messages)
      messages << { role: "user", content: prompt }

      if function_requests.present? && function_results.present?
        messages << {
          role: "assistant",
          content: nil,
          tool_calls: function_requests.map do |fr|
            {
              id: fr.call_id,
              type: "function",
              function: { name: fr.function_name, arguments: fr.function_args }
            }
          end
        }

        function_results.each do |result|
          messages << {
            role: "tool",
            tool_call_id: result[:call_id],
            content: result[:output].to_s
          }
        end
      end

      messages
    end

    def parse_response(raw_response)
      message = raw_response.dig("choices", 0, "message") || {}
      tool_calls = message["tool_calls"] || []

      Provider::LlmConcept::ChatResponse.new(
        id: raw_response.dig("id"),
        model: raw_response.dig("model"),
        messages: message["content"].present? ? [
          Provider::LlmConcept::ChatMessage.new(id: raw_response.dig("id"), output_text: message["content"])
        ] : [],
        function_requests: tool_calls.map do |tc|
          Provider::LlmConcept::ChatFunctionRequest.new(
            id: tc["id"],
            call_id: tc["id"],
            function_name: tc.dig("function", "name"),
            function_args: tc.dig("function", "arguments")
          )
        end
      )
    end

    # Accumula i chunk di streaming (formato Chat Completions: solo "delta", niente evento finale
    # con l'oggetto completo come nella Responses API di OpenAI), per ricostruire la risposta finale.
    class StreamAccumulator
      def initialize
        @id = nil
        @model = nil
        @content = ""
        @consumed_length = 0
        @tool_calls = {}
      end

      def add(chunk)
        @id ||= chunk["id"]
        @model ||= chunk["model"]

        delta = chunk.dig("choices", 0, "delta") || {}

        @content += delta["content"] if delta["content"]

        (delta["tool_calls"] || []).each do |tc_delta|
          index = tc_delta["index"] || 0
          entry = (@tool_calls[index] ||= { id: nil, name: nil, arguments: +"" })
          entry[:id] ||= tc_delta["id"]
          entry[:name] ||= tc_delta.dig("function", "name")
          entry[:arguments] << tc_delta.dig("function", "arguments").to_s
        end
      end

      def consume_new_text!
        return nil if @content.length <= @consumed_length
        new_text = @content[@consumed_length..]
        @consumed_length = @content.length
        new_text
      end

      def to_chat_response
        Provider::LlmConcept::ChatResponse.new(
          id: @id,
          model: @model,
          messages: @content.present? ? [ Provider::LlmConcept::ChatMessage.new(id: @id, output_text: @content) ] : [],
          function_requests: @tool_calls.values.map do |tc|
            Provider::LlmConcept::ChatFunctionRequest.new(
              id: tc[:id],
              call_id: tc[:id],
              function_name: tc[:name],
              function_args: tc[:arguments]
            )
          end
        )
      end
    end
end
