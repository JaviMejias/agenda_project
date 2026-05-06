import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progressBar"]

  connect() {
    requestAnimationFrame(() => {
      this.element.classList.remove("opacity-0", "translate-y-4", "translate-x-full")
      this.element.classList.add("opacity-100", "translate-y-0", "translate-x-0")

      if (this.hasProgressBarTarget) {
        void this.progressBarTarget.offsetWidth
        this.progressBarTarget.style.transition = "width 3s linear"
        this.progressBarTarget.style.width = "0%"
      }
    })

    this.timeout = setTimeout(() => {
      this.close()
    }, 3000)
  }

  close(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    clearTimeout(this.timeout)

    this.element.classList.remove("opacity-100", "translate-y-0", "translate-x-0")
    this.element.classList.add("opacity-0", "translate-x-full")

    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
