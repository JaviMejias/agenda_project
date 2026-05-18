import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clientSection", "submitButton", "totalLabel", "clientId"]

  connect() {
    this.checkValidation()
  }

  toggle(event) {
    const status = event.target.value
    if (status === "blocked") {
      this.clientSectionTarget.classList.add("hidden")
      this.submitButtonTarget.value = "Bloquear Propiedad"
      if (this.hasTotalLabelTarget) this.totalLabelTarget.textContent = "Pérdida Estimada"

      if (this.hasClientIdTarget) {
        const tomSelect = this.clientIdTarget.tomselect
        if (tomSelect) tomSelect.clear()
        else this.clientIdTarget.value = ""
      }
    } else {
      this.clientSectionTarget.classList.remove("hidden")
      this.submitButtonTarget.value = "Confirmar Reserva"
      if (this.hasTotalLabelTarget) this.totalLabelTarget.textContent = "Total Estimado"
    }
    this.checkValidation()
  }

  handleValidationCheck(event) {
    this.checkValidation()
  }

  checkValidation() {
    if (!this.hasSubmitButtonTarget) return

    const form = this.element.closest('form')
    if (!form) return

    const startTime = form.querySelector('input[name="reservation[start_time]"]')?.value
    const endTime = form.querySelector('input[name="reservation[end_time]"]')?.value
    const status = form.querySelector('input[name="reservation[status]"]:checked')?.value
    const clientId = form.querySelector('select[name="reservation[client_id]"]')?.value

    const hasDates = startTime && endTime
    const isBlocked = status === "blocked"
    const hasClient = clientId && clientId !== ""

    let isValid = false
    if (isBlocked) {
      isValid = !!hasDates
    } else {
      isValid = !!hasDates && !!hasClient
    }

    this.submitButtonTarget.disabled = !isValid
  }
}
