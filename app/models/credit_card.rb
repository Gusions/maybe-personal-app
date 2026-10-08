class CreditCard < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "credit_card" => { short: "Carta di credito", long: "Carta di Credito" },
    "revolving" => { short: "Revolving", long: "Carta di Credito Revolving" }
  }.freeze

  class << self
    def color
      "#F13636"
    end

    def icon
      "credit-card"
    end

    def classification
      "liability"
    end

    def display_name
      "Carte di Credito"
    end
  end

  def available_credit_money
    available_credit ? Money.new(available_credit, account.currency) : nil
  end

  def minimum_payment_money
    minimum_payment ? Money.new(minimum_payment, account.currency) : nil
  end

  def annual_fee_money
    annual_fee ? Money.new(annual_fee, account.currency) : nil
  end
end
