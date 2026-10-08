class OtherAsset < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "credito" => { short: "Credito", long: "Credito da riscuotere" }
  }.freeze

  class << self
    def color
      "#12B76A"
    end

    def icon
      "plus"
    end

    def classification
      "asset"
    end

    def display_name
      "Altri Attivi"
    end
  end
end
