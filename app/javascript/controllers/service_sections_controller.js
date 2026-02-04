import { Controller } from "@hotwired/stimulus"

// Controla el despliegue de las secciones "Datos del servicio" y "Configuración"
export default class extends Controller {
  static targets = ["datos", "config"]

  connect() {
    // Por defecto las secciones quedan colapsadas
    this.showDatos(false)
    this.showConfig(false)
  }

  toggleDatos() {
    const hidden = this.datosTarget.classList.contains("is-collapsed")
    this.showDatos(hidden)
  }

  toggleConfig() {
    const hidden = this.configTarget.classList.contains("is-collapsed")
    this.showConfig(hidden)
  }

  showDatos(show) {
    this.datosTarget.classList.toggle("is-collapsed", !show)
    this.datosTarget.hidden = !show
  }

  showConfig(show) {
    this.configTarget.classList.toggle("is-collapsed", !show)
    this.configTarget.hidden = !show
  }
}

