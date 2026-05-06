import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!this.hiddenInput) {
      this.hiddenInput = document.createElement("input")
      this.hiddenInput.type = "hidden"
      this.hiddenInput.name = this.element.name
      this.element.parentNode.insertBefore(this.hiddenInput, this.element.nextSibling)
      this.element.removeAttribute("name")
    }

    this.format()
  }

  format() {
    let rawValue = this.element.value.replace(/\D/g, "")

    this.hiddenInput.value = rawValue

    if (rawValue) {
      this.element.value = parseInt(rawValue, 10).toLocaleString("es-CL")
    } else {
      this.element.value = ""
    }
  }
}
