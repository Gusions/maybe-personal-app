# The shape of data expected by `confirm_dialog_controller.js` to override the
# default browser confirm API via Turbo.
class CustomConfirm
  class << self
    def for_resource_deletion(resource_name, high_severity: false)
      new(
        destructive: true,
        high_severity: high_severity,
        title: "Eliminare #{resource_name.downcase}?",
        body: "Sei sicuro di voler eliminare #{resource_name.downcase}? L'operazione non è reversibile.",
        btn_text: "Elimina #{resource_name.downcase}"
      )
    end
  end

  def initialize(title: default_title, body: default_body, btn_text: default_btn_text, destructive: false, high_severity: false)
    @title = title
    @body = body
    @btn_text = btn_text
    @btn_variant = derive_btn_variant(destructive, high_severity)
  end

  def to_data_attribute
    {
      title: title,
      body: body,
      confirmText: btn_text,
      variant: btn_variant
    }
  end

  private
    attr_reader :title, :body, :btn_text, :btn_variant

    def derive_btn_variant(destructive, high_severity)
      return "primary" unless destructive
      high_severity ? "destructive" : "outline-destructive"
    end

    def default_title
      "Sei sicuro?"
    end

    def default_body
      "L'operazione non è reversibile."
    end

    def default_btn_text
      "Conferma"
    end
end
