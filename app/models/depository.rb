class Depository < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "checking" => { short: "Conto corrente", long: "Conto Corrente" },
    "savings" => { short: "Risparmio", long: "Conto di Risparmio" },
    "deposito_vincolato" => { short: "Conto deposito", long: "Conto Deposito Vincolato" },
    "libretto_postale" => { short: "Libretto postale", long: "Libretto di Risparmio Postale" }
  }.freeze

  class << self
    def display_name
      "Liquidità"
    end

    def color
      "#875BF7"
    end

    def classification
      "asset"
    end

    def icon
      "landmark"
    end
  end
end
