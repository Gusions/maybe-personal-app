class SetItalianDefaultsForFamilies < ActiveRecord::Migration[7.2]
  def up
    change_column_default :families, :locale, from: "en", to: "it"
    change_column_default :families, :currency, from: "USD", to: "EUR"
    change_column_default :families, :date_format, from: "%m-%d-%Y", to: "%d/%m/%Y"
    change_column_default :families, :country, from: "US", to: "IT"

    Family.where(locale: "en").update_all(locale: "it")
    Family.where(currency: "USD").update_all(currency: "EUR")
    Family.where(date_format: "%m-%d-%Y").update_all(date_format: "%d/%m/%Y")
    Family.where(country: "US").update_all(country: "IT")
  end

  def down
    change_column_default :families, :locale, from: "it", to: "en"
    change_column_default :families, :currency, from: "EUR", to: "USD"
    change_column_default :families, :date_format, from: "%d/%m/%Y", to: "%m-%d-%Y"
    change_column_default :families, :country, from: "IT", to: "US"
  end
end
