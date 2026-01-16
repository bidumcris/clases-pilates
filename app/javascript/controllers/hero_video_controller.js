import { Controller } from "@hotwired/stimulus"

// Rota videos de fondo en el hero (uno a la vez).
// Requisitos de autoplay en navegadores: muted + playsinline.
export default class extends Controller {
  static targets = ["video"]
  static values = {
    sources: Array,
    intervalMs: { type: Number, default: 12000 },
  }

  connect() {
    this.index = 0
    this._onEnded = this.onEnded.bind(this)

    if (!this.hasVideoTarget || !this.sourcesValue?.length) return

    this.videoTarget.addEventListener("ended", this._onEnded)
    this.playIndex(0)
  }

  disconnect() {
    if (this.hasVideoTarget) {
      this.videoTarget.removeEventListener("ended", this._onEnded)
    }
    this.stopTimer()
  }

  onEnded() {
    this.next()
  }

  next() {
    if (!this.sourcesValue?.length) return
    const nextIndex = (this.index + 1) % this.sourcesValue.length
    this.playIndex(nextIndex)
  }

  playIndex(i) {
    this.index = i
    const src = this.sourcesValue[i]
    if (!src) return

    // Cambiar fuente y reproducir
    this.videoTarget.src = src
    this.videoTarget.load()

    const p = this.videoTarget.play()
    if (p && typeof p.catch === "function") {
      p.catch(() => {
        // Si el navegador bloquea autoplay, igual dejamos el video listo.
      })
    }

    // Fallback por tiempo (por si el "ended" no dispara o el video queda en loop)
    this.stopTimer()
    this.timer = setTimeout(() => this.next(), this.intervalMsValue)
  }

  stopTimer() {
    if (this.timer) clearTimeout(this.timer)
    this.timer = null
  }
}

