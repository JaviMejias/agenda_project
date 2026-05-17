import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submitButton"]

  connect() {
    this.validate()
  }

  check(event) {
    this.validate()
  }

  validate() {
    if (!this.hasSubmitButtonTarget) return

    // 1. Check dates (start_time and end_time hidden inputs)
    const startTime = this.element.querySelector('input[name="reservation[start_time]"]')?.value
    const endTime = this.element.querySelector('input[name="reservation[end_time]"]')?.value
    const hasDates = !!(startTime && endTime)

    // 2. Check guest fields
    const guestInputs = this.inputTargets

    const guestFieldsFilled = guestInputs.every(input => {
      if (input.required) {
        return input.value.trim() !== ""
      }
      return true
    })

    const isValid = hasDates && guestFieldsFilled

    this.submitButtonTarget.disabled = !isValid
  }
}
