module TransactionsHelper
  def transaction_search_filters
    [
      { key: "account_filter", label: "Conto", icon: "layers" },
      { key: "date_filter", label: "Data", icon: "calendar" },
      { key: "type_filter", label: "Tipo", icon: "tag" },
      { key: "amount_filter", label: "Importo", icon: "hash" },
      { key: "category_filter", label: "Categoria", icon: "shapes" },
      { key: "tag_filter", label: "Tag", icon: "tags" },
      { key: "merchant_filter", label: "Esercente", icon: "store" }
    ]
  end

  def get_transaction_search_filter_partial_path(filter)
    "transactions/searches/filters/#{filter[:key]}"
  end

  def get_default_transaction_search_filter
    transaction_search_filters[0]
  end
end
