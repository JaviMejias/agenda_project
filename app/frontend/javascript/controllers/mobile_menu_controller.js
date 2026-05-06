import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = ["menu", "iconOpen", "iconClose", "item"]

  connect() {
    this.isOpen = false
    
    this.menuTarget.style.maxHeight = "0px"
    this.menuTarget.style.overflow = "hidden"
    this.menuTarget.style.transition = "max-height 0.3s ease-in-out, opacity 0.3s ease-in-out"
    this.menuTarget.style.opacity = "0"
    this.menuTarget.classList.remove("hidden")

    
    this.itemTargets.forEach((item) => {
      item.style.transition = "opacity 0.25s ease, transform 0.25s ease"
      item.style.opacity = "0"
      item.style.transform = "translateY(-8px)"
    })
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.isOpen = true
    this.iconOpenTarget.classList.add("hidden")
    this.iconCloseTarget.classList.remove("hidden")

    
    this.menuTarget.style.maxHeight = `${this.menuTarget.scrollHeight}px`
    this.menuTarget.style.opacity = "1"

    
    this.itemTargets.forEach((item, index) => {
      setTimeout(() => {
        item.style.opacity = "1"
        item.style.transform = "translateY(0)"
      }, 50 + index * 60)
    })
  }

  close() {
    this.isOpen = false
    this.iconOpenTarget.classList.remove("hidden")
    this.iconCloseTarget.classList.add("hidden")

    
    this.itemTargets.forEach((item) => {
      item.style.opacity = "0"
      item.style.transform = "translateY(-8px)"
    })

    
    this.menuTarget.style.maxHeight = "0px"
    this.menuTarget.style.opacity = "0"
  }
}
