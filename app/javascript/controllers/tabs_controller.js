import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "content"]

  connect() {
    // Activar el primer tab por defecto
    this.showTab(0)
  }

  switch(event) {
    const index = this.buttonTargets.indexOf(event.currentTarget)
    this.showTab(index)
  }

  switchToLogin() {
    this.showTab(0)
  }

  switchToRegister() {
    this.showTab(1)
  }

  showTab(index) {
    // Desactivar todos los tabs
    this.buttonTargets.forEach((button, i) => {
      button.classList.toggle("active", i === index)
    })
    
    this.contentTargets.forEach((content, i) => {
      content.classList.toggle("active", i === index)
    })
  }
}

