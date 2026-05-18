import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["balanceDisplay"]

  connect() {
    if (this.inputElement && !this.hiddenInput) {
      this.hiddenInput = document.createElement("input")
      this.hiddenInput.type = "hidden"
      this.hiddenInput.name = this.inputElement.name
      this.inputElement.parentNode.insertBefore(this.hiddenInput, this.inputElement.nextSibling)
      this.inputElement.removeAttribute("name")
    }

    this.format()
  }

  get inputElement() {
    return this.element.tagName === "INPUT" ? this.element : this.element.querySelector("input")
  }

  format() {
    const inputEl = this.inputElement
    if (!inputEl) return

    let rawValue = inputEl.value.replace(/\D/g, "")

    let maxAttr = inputEl.getAttribute("data-currency-max-value")
    let numValue = rawValue !== "" ? parseInt(rawValue, 10) : 0

    if (maxAttr && rawValue !== "") {
      let maxValue = parseInt(maxAttr, 10)
      if (numValue > maxValue) {
        numValue = maxValue
        rawValue = maxValue.toString()
      }
    }

    if (this.hiddenInput) {
      this.hiddenInput.value = rawValue
    }

    if (rawValue) {
      inputEl.value = parseInt(rawValue, 10).toLocaleString("es-CL")
    } else {
      inputEl.value = ""
    }

    this.updateBalanceDisplay(numValue)
  }

  updateBalanceDisplay(currentValue) {
    if (!this.hasBalanceDisplayTarget) return

    let maxAttr = this.inputElement.getAttribute("data-currency-max-value")
    if (maxAttr) {
      let maxValue = parseInt(maxAttr, 10)
      let remaining = maxValue - currentValue

      let formattedRemaining = remaining.toLocaleString("es-CL")
      this.balanceDisplayTarget.textContent = "$" + formattedRemaining

      if (remaining === 0) {
        this.balanceDisplayTarget.className = "text-emerald-500 dark:text-emerald-400 font-black text-sm tracking-wide"
      } else {
        this.balanceDisplayTarget.className = "text-indigo-600 dark:text-indigo-400 font-black text-sm tracking-wide"
      }
    }
  }
}
