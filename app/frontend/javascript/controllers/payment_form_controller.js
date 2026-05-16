import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["methodSelect", "operationFields"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const selectedMethod = this.methodSelectTarget.value
    
    if (selectedMethod === "transfer" || selectedMethod === "other") {
      this.operationFieldsTarget.classList.remove("hidden")
      // Animate opening
      this.operationFieldsTarget.classList.add("animate-fade-in-up")
    } else {
      this.operationFieldsTarget.classList.add("hidden")
      this.operationFieldsTarget.classList.remove("animate-fade-in-up")
      
      // Clear values when hiding
      const inputs = this.operationFieldsTarget.querySelectorAll("input")
      inputs.forEach(input => {
        if (input.type !== "hidden") {
          input.value = ""
        }
      })
    }
  }
}
