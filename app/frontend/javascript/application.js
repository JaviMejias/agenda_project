import { Turbo } from "@hotwired/turbo-rails"
import Swal from "sweetalert2"
import "./controllers"

Turbo.config.forms.confirm = (message, element) => {
  return new Promise((resolve) => {
    Swal.fire({
      title: '¿Estás seguro?',
      text: message,
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#4f46e5',
      cancelButtonColor: '#ef4444',
      confirmButtonText: 'Sí, continuar',
      cancelButtonText: 'Cancelar',
      customClass: {
        popup: 'rounded-2xl',
        confirmButton: 'rounded-xl px-4 py-2 font-bold',
        cancelButton: 'rounded-xl px-4 py-2 font-bold'
      }
    }).then((result) => {
      resolve(result.isConfirmed)
    })
  })
}


document.addEventListener("turbo:click", () => {
  document.body.classList.add("turbo-loading")
})

document.addEventListener("turbo:render", () => {
  document.body.classList.remove("turbo-loading")
})

document.addEventListener("turbo:before-frame-render", () => {
  document.body.classList.remove("turbo-loading")
})

document.addEventListener("turbo:load", () => {
  document.body.classList.remove("turbo-loading")
})
