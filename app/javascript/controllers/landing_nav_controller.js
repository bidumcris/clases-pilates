import { Controller } from "@hotwired/stimulus"

// Controla el menú hamburguesa del header de la landing en móvil.
export default class extends Controller {
  static targets = ["menu", "toggle"]

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
  }

  toggle() {
    this.element.classList.toggle("is-open")
    const isOpen = this.element.classList.contains("is-open")
    if (this.hasMenuTarget) {
      this.menuTarget.setAttribute("aria-hidden", !isOpen)
    }
    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", isOpen)
      this.toggleTarget.setAttribute("aria-label", isOpen ? "Cerrar menú" : "Abrir menú")
    }
    if (isOpen) {
      document.addEventListener("click", this.closeOnClickOutside)
    } else {
      document.removeEventListener("click", this.closeOnClickOutside)
    }
  }

  close() {
    this.element.classList.remove("is-open")
    if (this.hasMenuTarget) {
      this.menuTarget.setAttribute("aria-hidden", "true")
    }
    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", "false")
      this.toggleTarget.setAttribute("aria-label", "Abrir menú")
    }
    document.removeEventListener("click", this.closeOnClickOutside)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
