import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.formatAll()
  }

  formatAll() {
    const inputs = this.element.querySelectorAll("[data-action*='input->rut#format']")
    inputs.forEach(input => {
      this.formatInput(input)
    })
  }

  formatInput(element) {
    let value = element.value.replace(/[^0-9kK]/g, '').toUpperCase()
    
    if (value.length <= 1) {
      element.value = value
      return
    }

    let body = value.slice(0, -1)
    let dv = value.slice(-1)

    let formatted = body.replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    
    if (formatted && dv) {
      element.value = `${formatted}-${dv}`
    } else {
      element.value = value
    }
  }

  format(event) {
    this.formatInput(event.target)
  }
}
