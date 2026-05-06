import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clientSection", "submitButton", "totalLabel"]

  toggle(event) {
    const status = event.target.value
    if (status === "blocked") {
      this.clientSectionTarget.classList.add("hidden")
      this.submitButtonTarget.value = "Bloquear Propiedad"
      if (this.hasTotalLabelTarget) this.totalLabelTarget.textContent = "Pérdida Estimada"
    } else {
      this.clientSectionTarget.classList.remove("hidden")
      this.submitButtonTarget.value = "Confirmar Reserva"
      if (this.hasTotalLabelTarget) this.totalLabelTarget.textContent = "Total Estimado"
    }
  }
}
