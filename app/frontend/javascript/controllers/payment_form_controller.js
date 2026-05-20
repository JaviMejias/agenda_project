import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["methodSelect", "operationFields", "typeSelect", "amountInput"]

  connect() {
    this.toggleFields()
    this.toggleMaxAmount()
  }

  toggleFields() {
    const selectedMethod = this.methodSelectTarget.value
    
    if (selectedMethod === "transfer" || selectedMethod === "other") {
      this.operationFieldsTarget.classList.remove("hidden")
      this.operationFieldsTarget.classList.add("animate-fade-in-up")
    } else {
      this.operationFieldsTarget.classList.add("hidden")
      this.operationFieldsTarget.classList.remove("animate-fade-in-up")
      
      const inputs = this.operationFieldsTarget.querySelectorAll("input")
      inputs.forEach(input => {
        if (input.type !== "hidden" && input.type !== "file") {
          input.value = ""
        }
      })
    }
  }

  toggleMaxAmount() {
    if (!this.hasTypeSelectTarget || !this.hasAmountInputTarget) return

    const type = this.typeSelectTarget.value
    const amountInput = this.amountInputTarget
    
    const maxAbono = amountInput.dataset.maxAbono
    const maxReembolso = amountInput.dataset.maxReembolso

    let newMax = type === "reembolso" ? maxReembolso : maxAbono
    
    amountInput.setAttribute("data-currency-max-value", newMax)

    const event = new Event("input", { bubbles: true })
    amountInput.dispatchEvent(event)
  }
}
