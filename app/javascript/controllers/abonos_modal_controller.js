import { Controller } from "@hotwired/stimulus"

// Abre/cierra el modal de Administración de abonos y carga el contenido vía fetch.
export default class extends Controller {
  static values = { url: String }

  open(event) {
    const url = this.urlValue
    if (!url) return

    event.preventDefault()
    event.stopPropagation()

    const modal = document.getElementById("abonos-modal")
    const body = modal?.querySelector("[data-abonos-modal-target=\"body\"]")
    if (!modal || !body) return

    body.innerHTML = "<p class=\"text-muted\">Cargando…</p>"
    modal.setAttribute("aria-hidden", "false")
    modal.classList.add("abonos-modal--open")

    fetch(url, { headers: { Accept: "text/html" } })
      .then((r) => {
        if (!r.ok) throw new Error("Error al cargar")
        return r.text()
      })
      .then((html) => {
        body.innerHTML = html
      })
      .catch(() => {
        body.innerHTML = "<p class=\"text-danger\">No se pudo cargar.</p>"
      })
  }

  close(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    const modal = document.getElementById("abonos-modal")
    if (!modal) return
    modal.setAttribute("aria-hidden", "true")
    modal.classList.remove("abonos-modal--open")
  }

  loadModificar(event) {
    const url = event.currentTarget.dataset.modificarAbonoUrl
    if (!url) return
    event.preventDefault()
    event.stopPropagation()
    const modal = document.getElementById("abonos-modal")
    const body = modal?.querySelector("[data-abonos-modal-target=\"body\"]")
    if (!body) return
    body.innerHTML = "<p class=\"text-muted\">Cargando…</p>"
    fetch(url, { headers: { Accept: "text/html" } })
      .then((r) => {
        if (!r.ok) throw new Error("Error al cargar")
        return r.text()
      })
      .then((html) => {
        body.innerHTML = html
      })
      .catch(() => {
        body.innerHTML = "<p class=\"text-danger\">No se pudo cargar.</p>"
      })
  }

  descartarModificar(event) {
    const wrapper = event.target.closest("[data-abonos-back-url]")
    const url = wrapper?.dataset.abonosBackUrl
    if (!url) return
    event.preventDefault()
    event.stopPropagation()
    const modal = document.getElementById("abonos-modal")
    const body = modal?.querySelector("[data-abonos-modal-target=\"body\"]")
    if (!body) return
    body.innerHTML = "<p class=\"text-muted\">Cargando…</p>"
    fetch(url, { headers: { Accept: "text/html" } })
      .then((r) => {
        if (!r.ok) throw new Error("Error al cargar")
        return r.text()
      })
      .then((html) => {
        body.innerHTML = html
      })
      .catch(() => {
        body.innerHTML = "<p class=\"text-danger\">No se pudo cargar.</p>"
      })
  }

  submitModificar(event) {
    event.preventDefault()
    const form = event.target
    const body = document.getElementById("abonos-modal")?.querySelector("[data-abonos-modal-target=\"body\"]")
    if (!body) return
    body.innerHTML = "<p class=\"text-muted\">Guardando…</p>"
    fetch(form.action, {
      method: "PATCH",
      body: new FormData(form),
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        Accept: "text/html"
      }
    })
      .then((r) => r.text())
      .then((html) => {
        body.innerHTML = html
      })
      .catch(() => {
        body.innerHTML = "<p class=\"text-danger\">Error al guardar.</p>"
      })
  }
}
