import { Controller } from "@hotwired/stimulus"

// Abre/cierra el modal de detalle de clase y carga el contenido vía fetch.
// Se usa en cada barra del calendario (con data-class-modal-url-value) y en el propio modal (cerrar).
export default class extends Controller {
  static values = { url: String }

  open(event) {
    const url = this.urlValue
    if (!url) return

    event.preventDefault()
    event.stopPropagation()

    const modal = document.getElementById("class-modal")
    const body = modal?.querySelector("[data-class-modal-target=\"body\"]")
    if (!modal || !body) return

    body.innerHTML = "<p class=\"text-muted\">Cargando…</p>"
    modal.setAttribute("aria-hidden", "false")
    modal.classList.add("class-modal--open")

    fetch(url, { headers: { Accept: "text/html" } })
      .then((r) => {
        if (!r.ok) throw new Error("Error al cargar")
        return r.text()
      })
      .then((html) => {
        body.innerHTML = html
        const titleEl = body.querySelector("[data-modal-title]")
        const headerTitle = document.getElementById("class-modal-title")
        if (titleEl && headerTitle) {
          headerTitle.textContent = titleEl.getAttribute("data-modal-title") || "Clase"
          titleEl.remove()
        }
      })
      .catch(() => {
        body.innerHTML = "<p class=\"text-danger\">No se pudo cargar la clase.</p>"
      })
  }

  close(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    const modal = document.getElementById("class-modal")
    if (!modal) return
    modal.setAttribute("aria-hidden", "true")
    modal.classList.remove("class-modal--open")
  }
}
