import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.isOpen = !this.menuTarget.classList.contains("hidden")
  }

  toggle(event) {
    if (event) event.stopPropagation()
    
    if (this.menuTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.isOpen = true
    
    // Remove hidden first
    this.menuTarget.classList.remove("hidden")
    
    // Trigger animation by adding classes in next frame
    requestAnimationFrame(() => {
      this.menuTarget.classList.add("opacity-100", "scale-100")
      this.menuTarget.classList.remove("opacity-0", "scale-95")
    })
    
    // Mark button as active
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
        if (!event.target.closest('[data-action*="dropdown#hide"]')) return
      }
    }

    this.isOpen = false
    
    // Start exit animation
    this.menuTarget.classList.add("opacity-0", "scale-95")
    this.menuTarget.classList.remove("opacity-100", "scale-100")
    
    // Wait for animation to finish before adding hidden
    setTimeout(() => {
      if (!this.isOpen) {
        this.menuTarget.classList.add("hidden")
      }
    }, 200)

    // Unmark button
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
