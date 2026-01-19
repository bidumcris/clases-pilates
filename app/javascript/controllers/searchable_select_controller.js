import { Controller } from "@hotwired/stimulus"

// Hace un <select> "buscable" sin dependencias.
// Uso:
// <div data-controller="searchable-select">
//   <select data-searchable-select-target="select">...</select>
// </div>
export default class extends Controller {
  static targets = ["select"]

  connect() {
    if (!this.hasSelectTarget) return
    if (this.element.dataset.searchableSelectInitialized === "1") return
    this.element.dataset.searchableSelectInitialized = "1"

    this.input = document.createElement("input")
    this.input.type = "search"
    this.input.className = this.selectTarget.className
    this.input.placeholder = this.placeholderValue()
    this.input.autocomplete = "off"
    this.input.spellcheck = false

    // Insertar el input arriba del select
    this.selectTarget.parentNode.insertBefore(this.input, this.selectTarget)
    this.input.style.marginBottom = "0.5rem"

    this.onInput = this.onInput.bind(this)
    this.input.addEventListener("input", this.onInput)
  }

  disconnect() {
    this.input?.removeEventListener("input", this.onInput)
  }

  placeholderValue() {
    return this.selectTarget.dataset.searchPlaceholder || "Buscar..."
  }

  onInput() {
    const q = (this.input.value || "").trim().toLowerCase()
    const options = Array.from(this.selectTarget.options)

    options.forEach((opt) => {
      // siempre mostrar el prompt/vacío
      if (opt.value === "") {
        opt.hidden = false
        return
      }
      if (!q) {
        opt.hidden = false
        return
      }
      const text = (opt.textContent || "").toLowerCase()
      opt.hidden = !text.includes(q)
    })
  }
}

