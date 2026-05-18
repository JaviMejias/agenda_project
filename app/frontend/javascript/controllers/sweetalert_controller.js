import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
  static values = {
    title: { type: String, default: "¿Estás seguro?" },
    text: { type: String, default: "Esta acción no se puede deshacer." },
    icon: { type: String, default: "warning" },
    confirmButtonText: { type: String, default: "Sí, continuar" },
    cancelButtonText: { type: String, default: "Cancelar" }
  }

  confirm(event) {
    event.preventDefault()

    Swal.fire({
      title: this.titleValue,
      text: this.textValue,
      icon: this.iconValue,
      showCancelButton: true,
      confirmButtonColor: '#4f46e5',
      cancelButtonColor: '#ef4444',
      confirmButtonText: this.confirmButtonTextValue,
      cancelButtonText: this.cancelButtonTextValue,
      customClass: {
        popup: 'rounded-2xl',
        confirmButton: 'rounded-xl px-4 py-2 font-bold shadow-md',
        cancelButton: 'rounded-xl px-4 py-2 font-bold shadow-md'
      }
    }).then((result) => {
      if (result.isConfirmed) {
        if (this.element.tagName === "FORM") {
          this.element.requestSubmit()
        } else if (this.element.tagName === "A" || this.element.tagName === "BUTTON") {
        }
      }
    })
  }

  showToast(event) {
    if (event) event.preventDefault()

    Swal.fire({
      toast: true,
      position: 'top-end',
      icon: this.iconValue || 'success',
      title: this.titleValue || '¡Éxito!',
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true,
      customClass: {
        popup: 'mt-16'
      }
    })
  }
}
