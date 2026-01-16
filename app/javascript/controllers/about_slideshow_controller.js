import { Controller } from "@hotwired/stimulus"

// Slideshow de imágenes (una sola <img> y se va cambiando el src).
export default class extends Controller {
  static targets = ["img"]
  static values = {
    sources: Array,
    intervalMs: { type: Number, default: 6500 },
  }

  connect() {
    this.index = 0
    if (!this.hasImgTarget || !this.sourcesValue?.length) return

    this.show(0, { immediate: true })
    this.start()
  }

  disconnect() {
    this.stop()
  }

  start() {
    this.stop()
    this.timer = setInterval(() => this.next(), this.intervalMsValue)
  }

  stop() {
    if (this.timer) clearInterval(this.timer)
    this.timer = null
  }

  next() {
    if (!this.sourcesValue?.length) return
    const nextIndex = (this.index + 1) % this.sourcesValue.length
    this.show(nextIndex)
  }

  show(i, { immediate = false } = {}) {
    const src = this.sourcesValue[i]
    if (!src) return

    this.index = i

    // Preload siguiente para que el cambio sea instantáneo
    const preloadIndex = (i + 1) % this.sourcesValue.length
    const preloadSrc = this.sourcesValue[preloadIndex]
    if (preloadSrc) {
      const img = new Image()
      img.src = preloadSrc
    }

    if (immediate) {
      this.imgTarget.src = src
      return
    }

    this.imgTarget.classList.add("is-fading")
    window.setTimeout(() => {
      this.imgTarget.src = src
      this.imgTarget.onload = () => {
        this.imgTarget.classList.remove("is-fading")
      }
    }, 180)
  }
}

