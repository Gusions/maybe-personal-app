class UI::Account::BalanceReconciliation < ApplicationComponent
  attr_reader :balance, :account

  def initialize(balance:, account:)
    @balance = balance
    @account = account
  end

  def reconciliation_items
    case account.accountable_type
    when "Depository", "OtherAsset", "OtherLiability"
      default_items
    when "CreditCard"
      credit_card_items
    when "Investment"
      investment_items
    when "Loan"
      loan_items
    when "Property", "Vehicle"
      asset_items
    when "Crypto"
      crypto_items
    else
      default_items
    end
  end

  private

    def default_items
      items = [
        { label: "Saldo iniziale", value: balance.start_balance_money, tooltip: "Il saldo del conto all'inizio di questa giornata", style: :start },
        { label: "Flusso di cassa netto", value: net_cash_flow, tooltip: "Variazione netta del saldo dovuta a tutte le transazioni del giorno", style: :flow }
      ]

      if has_adjustments?
        items << { label: "Saldo finale (prima delle rettifiche)", value: end_balance_before_adjustments, tooltip: "Il saldo calcolato dopo tutte le transazioni", style: :subtotal }
        items << { label: "Rettifiche", value: total_adjustments, tooltip: "Riconciliazioni manuali o altre rettifiche", style: :adjustment }
      end

      items << { label: "Saldo finale", value: balance.end_balance_money, tooltip: "Il saldo finale del conto per la giornata", style: :final }
      items
    end

    def credit_card_items
      items = [
        { label: "Saldo iniziale", value: balance.start_balance_money, tooltip: "Il saldo dovuto all'inizio di questa giornata", style: :start },
        { label: "Spese", value: balance.cash_outflows_money, tooltip: "Nuove spese effettuate durante la giornata", style: :flow },
        { label: "Pagamenti", value: balance.cash_inflows_money * -1, tooltip: "Pagamenti effettuati sulla carta durante la giornata", style: :flow }
      ]

      if has_adjustments?
        items << { label: "Saldo finale (prima delle rettifiche)", value: end_balance_before_adjustments, tooltip: "Il saldo calcolato dopo tutte le transazioni", style: :subtotal }
        items << { label: "Rettifiche", value: total_adjustments, tooltip: "Riconciliazioni manuali o altre rettifiche", style: :adjustment }
      end

      items << { label: "Saldo finale", value: balance.end_balance_money, tooltip: "Il saldo dovuto finale per la giornata", style: :final }
      items
    end

    def investment_items
      items = [
        { label: "Saldo iniziale", value: balance.start_balance_money, tooltip: "Il valore totale del portafoglio all'inizio di questa giornata", style: :start }
      ]

      # Change in brokerage cash (includes deposits, withdrawals, and cash from trades)
      items << { label: "Variazione liquidità", value: net_cash_flow, tooltip: "Variazione netta della liquidità dovuta a depositi, prelievi e operazioni", style: :flow }

      # Change in holdings from trading activity
      items << { label: "Variazione posizioni (acquisti/vendite)", value: net_non_cash_flow, tooltip: "Impatto sulle posizioni dovuto all'acquisto e alla vendita di titoli", style: :flow }

      # Market price changes
      items << { label: "Variazione posizioni (andamento di mercato)", value: balance.net_market_flows_money, tooltip: "Variazione del valore delle posizioni dovuta ai movimenti di mercato", style: :flow }

      if has_adjustments?
        items << { label: "Saldo finale (prima delle rettifiche)", value: end_balance_before_adjustments, tooltip: "Il saldo calcolato dopo tutta l'attività", style: :subtotal }
        items << { label: "Rettifiche", value: total_adjustments, tooltip: "Riconciliazioni manuali o altre rettifiche", style: :adjustment }
      end

      items << { label: "Saldo finale", value: balance.end_balance_money, tooltip: "Il valore finale del portafoglio per la giornata", style: :final }
      items
    end

    def loan_items
      items = [
        { label: "Capitale iniziale", value: balance.start_balance_money, tooltip: "Il capitale residuo all'inizio di questa giornata", style: :start },
        { label: "Variazione netta capitale", value: net_non_cash_flow, tooltip: "Pagamenti sul capitale e nuovi prestiti durante la giornata", style: :flow }
      ]

      if has_adjustments?
        items << { label: "Capitale finale (prima delle rettifiche)", value: end_balance_before_adjustments, tooltip: "Il capitale calcolato dopo tutte le transazioni", style: :subtotal }
        items << { label: "Rettifiche", value: balance.non_cash_adjustments_money, tooltip: "Riconciliazioni manuali o altre rettifiche", style: :adjustment }
      end

      items << { label: "Capitale finale", value: balance.end_balance_money, tooltip: "Il capitale residuo finale per la giornata", style: :final }
      items
    end

    def asset_items # Property/Vehicle
      items = [
        { label: "Valore iniziale", value: balance.start_balance_money, tooltip: "Il valore dell'attivo all'inizio di questa giornata", style: :start },
        { label: "Variazione netta valore", value: net_total_flow, tooltip: "Tutte le variazioni di valore, incluse migliorie e deprezzamento", style: :flow }
      ]

      if has_adjustments?
        items << { label: "Valore finale (prima delle rettifiche)", value: end_balance_before_adjustments, tooltip: "Il valore calcolato dopo tutte le variazioni", style: :subtotal }
        items << { label: "Rettifiche", value: total_adjustments, tooltip: "Rettifiche manuali del valore o perizie", style: :adjustment }
      end

      items << { label: "Valore finale", value: balance.end_balance_money, tooltip: "Il valore finale dell'attivo per la giornata", style: :final }
      items
    end

    def crypto_items
      items = [
        { label: "Saldo iniziale", value: balance.start_balance_money, tooltip: "Il valore delle posizioni crypto all'inizio di questa giornata", style: :start }
      ]

      items << { label: "Acquisti", value: balance.cash_outflows_money * -1, tooltip: "Acquisti di crypto durante la giornata", style: :flow } if balance.cash_outflows != 0
      items << { label: "Vendite", value: balance.cash_inflows_money, tooltip: "Vendite di crypto durante la giornata", style: :flow } if balance.cash_inflows != 0
      items << { label: "Variazioni di mercato", value: balance.net_market_flows_money, tooltip: "Variazioni di valore dovute ai movimenti di mercato", style: :flow } if balance.net_market_flows != 0

      if has_adjustments?
        items << { label: "Saldo finale (prima delle rettifiche)", value: end_balance_before_adjustments, tooltip: "Il saldo calcolato dopo tutta l'attività", style: :subtotal }
        items << { label: "Rettifiche", value: total_adjustments, tooltip: "Riconciliazioni manuali o altre rettifiche", style: :adjustment }
      end

      items << { label: "Saldo finale", value: balance.end_balance_money, tooltip: "Il valore finale delle posizioni crypto per la giornata", style: :final }
      items
    end

    def net_cash_flow
      balance.cash_inflows_money - balance.cash_outflows_money
    end

    def net_non_cash_flow
      balance.non_cash_inflows_money - balance.non_cash_outflows_money
    end

    def net_total_flow
      net_cash_flow + net_non_cash_flow + balance.net_market_flows_money
    end

    def total_adjustments
      balance.cash_adjustments_money + balance.non_cash_adjustments_money
    end

    def has_adjustments?
      balance.cash_adjustments != 0 || balance.non_cash_adjustments != 0
    end

    def end_balance_before_adjustments
      balance.end_balance_money - total_adjustments
    end
end
