import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { autoHide: Number }

  connect() {
    if (this.autoHideValue > 0) {
      setTimeout(() => {
        this.hide()
      }, this.autoHideValue)
    }
  }

  hide() {
    this.element.style.transition = "opacity 0.3s"
    this.element.style.opacity = "0"
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}

