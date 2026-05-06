import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  format(event) {
    let value = event.target.value.replace(/[^0-9kK]/g, '').toUpperCase()
    
    if (value.length <= 1) {
      event.target.value = value
      return
    }

    let body = value.slice(0, -1)
    let dv = value.slice(-1)

    let formatted = body.replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    
    if (formatted && dv) {
      event.target.value = `${formatted}-${dv}`
    } else {
      event.target.value = value
    }
  }
}
