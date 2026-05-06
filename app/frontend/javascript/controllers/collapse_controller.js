import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { open: Boolean }

  connect() {
    if (!this.openValue) {
      this.contentTarget.style.maxHeight = "0px"
      this.contentTarget.style.opacity = "0"
      this.contentTarget.style.overflow = "hidden"
    } else {
      this.contentTarget.style.maxHeight = "none"
      this.contentTarget.style.opacity = "1"
    }
  }

  toggle() {
    this.openValue = !this.openValue
    
    if (this.openValue) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    const height = this.contentTarget.scrollHeight
    this.contentTarget.style.maxHeight = height + "px"
    this.contentTarget.style.opacity = "1"
    
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = "rotate(180deg)"
    }

    
    setTimeout(() => {
      if (this.openValue) this.contentTarget.style.maxHeight = "none"
    }, 500)
  }

  close() {
    const height = this.contentTarget.scrollHeight
    this.contentTarget.style.maxHeight = height + "px"
    
    
    this.contentTarget.offsetHeight

    this.contentTarget.style.maxHeight = "0px"
    this.contentTarget.style.opacity = "0"

    if (this.hasIconTarget) {
      this.iconTarget.style.transform = "rotate(0deg)"
    }
  }
}
