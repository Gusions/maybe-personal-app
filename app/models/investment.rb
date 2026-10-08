class Investment < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "brokerage" => { short: "Conto titoli", long: "Conto titoli (Brokerage)" },
    "fondo_pensione_negoziale" => { short: "Fondo negoziale", long: "Fondo Pensione Negoziale" },
    "fondo_pensione_aperto" => { short: "Fondo aperto", long: "Fondo Pensione Aperto" },
    "pip" => { short: "PIP", long: "PIP - Piano Individuale Pensionistico" },
    "fondo_comune" => { short: "Fondo comune", long: "Fondo Comune d'Investimento" },
    "etf" => { short: "ETF", long: "ETF" },
    "obbligazioni" => { short: "Obbligazioni", long: "Obbligazioni (BTP/BOT/Corporate)" },
    "polizza_vita" => { short: "Polizza vita", long: "Polizza Vita (Ramo I/III)" },
    "pac" => { short: "PAC", long: "Piano di Accumulo del Capitale (PAC)" }
  }.freeze

  class << self
    def color
      "#1570EF"
    end

    def classification
      "asset"
    end

    def icon
      "line-chart"
    end

    def display_name
      "Investimenti"
    end
  end
end
