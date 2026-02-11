import { Controller } from "@hotwired/stimulus"

// Abre/cierra el modal secundario de "Etiqueta y cupo" (dentro del modal de la clase).
export default class extends Controller {
  static targets = ["modal"]

  open() {
    if (!this.hasModalTarget) return
    this.modalTarget.classList.add("etiqueta-modal--open")
    this.modalTarget.setAttribute("aria-hidden", "false")
  }

  close(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    if (!this.hasModalTarget) return
    this.modalTarget.classList.remove("etiqueta-modal--open")
    this.modalTarget.setAttribute("aria-hidden", "true")
  }
}
