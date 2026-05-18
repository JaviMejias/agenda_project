import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "overlay", "content"]

  connect() {
  }

  open(e) {
    if (e) e.preventDefault()
    this.dialogTarget.classList.remove("hidden")

    setTimeout(() => {
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.remove("opacity-0")
      }
      if (this.hasContentTarget) {
        this.contentTarget.classList.remove("opacity-0", "scale-95", "translate-y-4")
        this.contentTarget.classList.add("opacity-100", "scale-100", "translate-y-0")
      }
    }, 10)

    document.body.classList.add("overflow-hidden")
  }

  close(e) {
    if (e) e.preventDefault()

    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("opacity-0")
    }
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("opacity-100", "scale-100", "translate-y-0")
      this.contentTarget.classList.add("opacity-0", "scale-95", "translate-y-4")
    }

    setTimeout(() => {
      this.dialogTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }, 300)
  }

  stopPropagation(e) {
    if (e) e.stopPropagation()
  }
}
