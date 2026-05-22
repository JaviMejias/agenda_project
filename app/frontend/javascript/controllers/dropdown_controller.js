import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.isOpen = !this.menuTarget.classList.contains("hidden")
  }

  toggle(event) {
    if (this.menuTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
  }

  stop(event) {
    event.stopPropagation()
  }

  show() {
    this.isOpen = true

    this.menuTarget.classList.remove("hidden")

    requestAnimationFrame(() => {
      this.menuTarget.classList.add("opacity-100", "scale-100")
      this.menuTarget.classList.remove("opacity-0", "scale-95")
    })

    if (this.hasButtonTarget) {
      this.buttonTarget.classList.add("ring-2", "ring-indigo-500/50", "bg-indigo-50", "dark:bg-indigo-900/40", "text-indigo-600", "dark:text-indigo-400")
      this.buttonTarget.classList.remove("text-gray-400")
    }

    if (window.innerWidth < 640) {
      document.body.classList.add("overflow-hidden")
    }
  }

  hide(event) {
    if (event && event.type === "click") {
      if (this.element.contains(event.target)) {
        const closestHider = event.target.closest('[data-action*="dropdown#hide"]')
        if (!closestHider || closestHider === this.element) return
      }
    }

    this.isOpen = false

    this.menuTarget.classList.add("opacity-0", "scale-95")
    this.menuTarget.classList.remove("opacity-100", "scale-100")

    setTimeout(() => {
      if (!this.isOpen) {
        this.menuTarget.classList.add("hidden")
      }
    }, 200)

    if (this.hasButtonTarget) {
      this.buttonTarget.classList.remove("ring-2", "ring-indigo-500/50", "bg-indigo-50", "dark:bg-indigo-900/40", "text-indigo-600", "dark:text-indigo-400")
      this.buttonTarget.classList.add("text-gray-400")
    }

    document.body.classList.remove("overflow-hidden")
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }
}
