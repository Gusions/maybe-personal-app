module PlaidAccount::TypeMappable
  extend ActiveSupport::Concern

  UnknownAccountTypeError = Class.new(StandardError)

  def map_accountable(plaid_type)
    accountable_class = TYPE_MAPPING.dig(
      plaid_type.to_sym,
      :accountable
    )

    unless accountable_class
      raise UnknownAccountTypeError, "Unknown account type: #{plaid_type}"
    end

    accountable_class.new
  end

  def map_subtype(plaid_type, plaid_subtype)
    TYPE_MAPPING.dig(
      plaid_type.to_sym,
      :subtype_mapping,
      plaid_subtype
    ) || "other"
  end

  # Plaid Account Types -> Accountable Types
  # https://plaid.com/docs/api/accounts/#account-type-schema
  TYPE_MAPPING = {
    depository: {
      accountable: Depository,
      subtype_mapping: {
        "checking" => "checking",
        "savings" => "savings",
        "cd" => "deposito_vincolato",
        "money market" => "deposito_vincolato"
      }
    },
    credit: {
      accountable: CreditCard,
      subtype_mapping: {
        "credit card" => "credit_card"
      }
    },
    loan: {
      accountable: Loan,
      subtype_mapping: {
        "mortgage" => "mortgage",
        "student" => "student",
        "auto" => "auto",
        "business" => "business",
        "home equity" => "home_equity",
        "line of credit" => "line_of_credit"
      }
    },
    investment: {
      accountable: Investment,
      subtype_mapping: {
        "brokerage" => "brokerage",
        "pension" => "fondo_pensione_aperto",
        "retirement" => "pip",
        "401k" => "fondo_pensione_negoziale",
        "roth 401k" => "fondo_pensione_negoziale",
        "mutual fund" => "fondo_comune",
        "roth" => "pip",
        "ira" => "pip"
      }
    },
    other: {
      accountable: OtherAsset,
      subtype_mapping: {}
    }
  }
end
