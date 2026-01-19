import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "email", "whatsapp", "reason", "message", "link"]
  static values = { phone: String }

  connect() {
    this.update()
  }

  update() {
    if (!this.hasLinkTarget) return

    const name = this.hasNameTarget ? this.nameTarget.value.trim() : ""
    const email = this.hasEmailTarget ? this.emailTarget.value.trim() : ""
    const whatsapp = this.hasWhatsappTarget ? this.whatsappTarget.value.trim() : ""
    const reason = this.hasReasonTarget ? this.reasonTarget.value.trim() : ""
    const message = this.hasMessageTarget ? this.messageTarget.value.trim() : ""

    const lines = [
      "Hola! Quiero hacer una consulta 🙌",
      name ? `Nombre: ${name}` : null,
      email ? `Email: ${email}` : null,
      whatsapp ? `WhatsApp: ${whatsapp}` : null,
      reason ? `Motivo: ${reason}` : null,
      message ? `Mensaje: ${message}` : null
    ].filter(Boolean)

    const text = encodeURIComponent(lines.join("\n"))
    const phone = this.phoneValue || "5493584830778"

    this.linkTarget.href = `https://wa.me/${phone}?text=${text}`
  }
}

