import { Controller } from "@hotwired/stimulus"

// Toggle expanded details panel when clicking the card body (not the action buttons).
export default class extends Controller {
  toggle(event) {
    if (event.target.closest(".admin-student-card__actions")) return
    const expanded = this.element.classList.toggle("admin-student-card--expanded")
    const toggleEl = this.element.querySelector("[data-action*='toggle']")
    const panelEl = this.element.querySelector(".admin-student-card__details")
    if (toggleEl) toggleEl.setAttribute("aria-expanded", expanded)
    if (panelEl) panelEl.setAttribute("aria-hidden", !expanded)
  }
}
