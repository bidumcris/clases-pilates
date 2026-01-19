// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Modal de confirmación para data-turbo-confirm (Turbo.config.forms.confirm)
document.addEventListener("turbo:load", () => {
  const modal = document.getElementById("confirm-modal")
  if (!modal || !window.Turbo?.config?.forms) return

  const messageEl = document.getElementById("confirm-modal-message")
  const cancelBtn = document.getElementById("confirm-modal-cancel")
  const confirmBtn = document.getElementById("confirm-modal-confirm")
  const backdrop = document.getElementById("confirm-modal-backdrop")

  const open = (message) => {
    messageEl.textContent = message
    modal.style.display = "block"
    modal.setAttribute("aria-hidden", "false")
  }

  const close = () => {
    modal.style.display = "none"
    modal.setAttribute("aria-hidden", "true")
  }

  Turbo.config.forms.confirm = (message) => {
    return new Promise((resolve) => {
      open(message)

      const onCancel = () => {
        cleanup()
        close()
        resolve(false)
      }

      const onConfirm = () => {
        cleanup()
        close()
        resolve(true)
      }

      const cleanup = () => {
        cancelBtn.removeEventListener("click", onCancel)
        confirmBtn.removeEventListener("click", onConfirm)
        backdrop?.removeEventListener("click", onCancel)
      }

      cancelBtn.addEventListener("click", onCancel)
      confirmBtn.addEventListener("click", onConfirm)
      backdrop?.addEventListener("click", onCancel)
    })
  }
})
