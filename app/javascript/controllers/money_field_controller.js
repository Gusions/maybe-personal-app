import { Controller } from "@hotwired/stimulus";
import { CurrenciesService } from "services/currencies_service";

// Connects to data-controller="money-field"
// when currency select change, update the input value with the correct placeholder and step
export default class extends Controller {
  static targets = ["amount", "currency", "symbol"];

  handleCurrencyChange(e) {
    const selectedCurrency = e.target.value;
    this.updateAmount(selectedCurrency);
  }

  // L'importo è un input di testo libero (non type="number"), quindi accetta sia "5000.50"
  // che il formato italiano "5000,50" o "1.235,31" (punto delle migliaia + virgola decimale).
  // Qui lo normalizziamo sempre nel formato con il punto come separatore decimale, che è
  // quello che il server si aspetta.
  normalizeAmount(e) {
    const input = e.target;
    const raw = input.value;

    if (!raw) return;

    const hasComma = raw.includes(",");
    const hasDot = raw.includes(".");

    let normalized = raw;

    if (hasComma && hasDot) {
      normalized = raw.replace(/\./g, "").replace(",", ".");
    } else if (hasComma) {
      normalized = raw.replace(",", ".");
    }

    if (normalized !== raw) {
      input.value = normalized;
    }
  }

  updateAmount(currency) {
    new CurrenciesService().get(currency).then((currency) => {
      this.amountTarget.step = currency.step;

      if (Number.isFinite(this.amountTarget.value)) {
        this.amountTarget.value = Number.parseFloat(
          this.amountTarget.value,
        ).toFixed(currency.default_precision);
      }

      this.symbolTarget.innerText = currency.symbol;
    });
  }
}
