import { Controller } from "@hotwired/stimulus"

// Modal de confirmación antes de reservar con recupero.
// Al hacer "Confirma" se envía el formulario (POST a reservations).
export default class extends Controller {
  static targets = ["modal", "pilatesClassIdInput"]
  static params = { pilatesClassId: String }

  open(event) {
    const pilatesClassId = event.params.pilatesClassId
    if (!pilatesClassId) return

    event.preventDefault()
    event.stopPropagation()

    if (this.hasPilatesClassIdInputTarget) {
      this.pilatesClassIdInputTarget.value = pilatesClassId
    }
    if (this.hasModalTarget) {
      this.modalTarget.setAttribute("aria-hidden", "false")
      this.modalTarget.classList.add("recupero-confirm-modal--open")
    }
  }

  close(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    if (this.hasModalTarget) {
      this.modalTarget.setAttribute("aria-hidden", "true")
      this.modalTarget.classList.remove("recupero-confirm-modal--open")
    }
  }
}
