class Property < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "appartamento" => { short: "Appartamento", long: "Appartamento" },
    "villa" => { short: "Villa", long: "Villa / Villetta" },
    "attico" => { short: "Attico", long: "Attico / Mansarda" },
    "rustico" => { short: "Rustico", long: "Rustico / Casale" },
    "immobile_commerciale" => { short: "Commerciale", long: "Immobile commerciale" },
    "box_garage" => { short: "Box/Garage", long: "Box auto / Garage" },
    "terreno" => { short: "Terreno", long: "Terreno" },
    "investimento" => { short: "Investimento", long: "Immobile da investimento" },
    "seconda_casa" => { short: "Seconda casa", long: "Seconda casa" }
  }.freeze

  has_one :address, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :address

  attribute :area_unit, :string, default: "sqm"

  class << self
    def icon
      "home"
    end

    def color
      "#06AED4"
    end

    def classification
      "asset"
    end

    def display_name
      "Immobili"
    end
  end

  def area
    Measurement.new(area_value, area_unit) if area_value.present?
  end

  def purchase_price
    first_valuation_amount
  end

  def trend
    Trend.new(current: account.balance_money, previous: first_valuation_amount)
  end

  def balance_display_name
    "valore di mercato"
  end

  def opening_balance_display_name
    "prezzo di acquisto originale"
  end

  private
    def first_valuation_amount
      account.entries.valuations.order(:date).first&.amount_money || account.balance_money
    end
end
