module Provider::LlmConcept
  extend ActiveSupport::Concern

  AutoCategorization = Data.define(:transaction_id, :category_name)

  def auto_categorize(transactions)
    raise NotImplementedError, "Subclasses must implement #auto_categorize"
  end

  AutoDetectedMerchant = Data.define(:transaction_id, :business_name, :business_url)

  def auto_detect_merchants(transactions)
    raise NotImplementedError, "Subclasses must implement #auto_detect_merchants"
  end

  ChatMessage = Data.define(:id, :output_text)
  ChatStreamChunk = Data.define(:type, :data)
  ChatResponse = Data.define(:id, :model, :messages, :function_requests)
  ChatFunctionRequest = Data.define(:id, :call_id, :function_name, :function_args)

  # `previous_messages` e `function_requests` sono usati dai provider (come Gemini) che non hanno
  # una memoria conversazionale lato server: permettono di ricostruire l'intera cronologia della
  # chat ad ogni chiamata. I provider con stato lato server (es. OpenAI, via `previous_response_id`)
  # possono ignorarli.
  def chat_response(prompt, model:, instructions: nil, functions: [], function_results: [], function_requests: [], previous_messages: [], streamer: nil, previous_response_id: nil)
    raise NotImplementedError, "Subclasses must implement #chat_response"
  end
end
