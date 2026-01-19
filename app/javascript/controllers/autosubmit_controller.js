import { Controller } from "@hotwired/stimulus"

// Auto-envía el formulario con debounce (ideal para filtros live)
// Uso:
// <form data-controller="autosubmit" data-autosubmit-delay-value="250">
//   <input data-action="input->autosubmit#queue" ... />
//   <select data-action="change->autosubmit#queue" ... />
// </form>
export default class extends Controller {
  static values = { delay: { type: Number, default: 250 } }

  queue() {
    window.clearTimeout(this._t)
    this._t = window.setTimeout(() => this.submit(), this.delayValue)
  }

  submit() {
    // requestSubmit respeta validaciones HTML y dispara submit real
    if (typeof this.element.requestSubmit === "function") {
      this.element.requestSubmit()
    } else {
      this.element.submit()
    }
  }
}

