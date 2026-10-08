module Breadcrumbable
  extend ActiveSupport::Concern

  # Etichette italiane per i breadcrumb generati automaticamente dal nome del
  # controller. Qualsiasi controller non presente qui ricade su
  # `controller_name.titleize` (inglese) come rete di sicurezza.
  CONTROLLER_LABELS = {
    "accountable_sparklines" => "Andamento conto",
    "accounts" => "Conti",
    "budget_categories" => "Categorie di Budget",
    "budgets" => "Budget",
    "categories" => "Categorie",
    "chats" => "Chat",
    "credit_cards" => "Carte di Credito",
    "cryptos" => "Crypto",
    "currencies" => "Valute",
    "current_sessions" => "Sessioni attive",
    "depositories" => "Conti deposito",
    "email_confirmations" => "Conferma email",
    "family_exports" => "Esportazione dati",
    "family_merchants" => "Esercenti",
    "holdings" => "Posizioni",
    "impersonation_sessions" => "Sessioni di supporto",
    "imports" => "Importazioni",
    "investments" => "Investimenti",
    "invitations" => "Inviti",
    "invite_codes" => "Codici di invito",
    "loans" => "Prestiti",
    "messages" => "Messaggi",
    "mfa" => "Autenticazione a due fattori",
    "onboardings" => "Configurazione iniziale",
    "other_assets" => "Altri attivi",
    "other_liabilities" => "Altre passività",
    "password_resets" => "Reimposta password",
    "passwords" => "Password",
    "plaid_items" => "Collegamenti bancari",
    "properties" => "Immobili",
    "registrations" => "Registrazione",
    "rules" => "Regole",
    "securities" => "Titoli",
    "sessions" => "Accessi",
    "subscriptions" => "Abbonamento",
    "tags" => "Tag",
    "trades" => "Operazioni",
    "transaction_categories" => "Categorie",
    "transactions" => "Transazioni",
    "transfer_matches" => "Abbinamento trasferimenti",
    "transfers" => "Trasferimenti",
    "users" => "Utenti",
    "valuations" => "Valutazioni",
    "vehicles" => "Veicoli",
    "webhooks" => "Webhook",
    "api_keys" => "Chiavi API",
    "billings" => "Fatturazione",
    "hostings" => "Self-hosting",
    "preferences" => "Preferenze",
    "profiles" => "Profilo",
    "usage" => "Utilizzo"
  }.freeze

  included do
    before_action :set_breadcrumbs
  end

  private
    # The default, unless specific controller or action explicitly overrides
    def set_breadcrumbs
      label = CONTROLLER_LABELS[controller_name] || controller_name.titleize
      @breadcrumbs = [ [ "Home", root_path ], [ label, nil ] ]
    end
end
