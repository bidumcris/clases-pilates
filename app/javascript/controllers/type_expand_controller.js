import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]
  static values = { expanded: { type: Boolean, default: false } }

  connect() {
    this.sync()
  }

  toggle() {
    this.expandedValue = !this.expandedValue
    this.sync()
  }

  sync() {
    if (this.hasContentTarget) {
      this.contentTarget.hidden = !this.expandedValue
      this.contentTarget.classList.toggle("is-open", this.expandedValue)
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.textContent = this.expandedValue ? "Ver menos" : "Ver más"
    }
  }
}

