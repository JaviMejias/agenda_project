import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    event.preventDefault()
    const imageUrl = event.currentTarget.src || event.currentTarget.dataset.url
    if (!imageUrl) return

    const lightbox = document.createElement('div')
    lightbox.id = 'lightbox-modal'
    lightbox.className = 'fixed inset-0 z-[100] bg-slate-950/90 backdrop-blur-md flex items-center justify-center p-4 sm:p-8 cursor-zoom-out animate-fade-in'
    lightbox.innerHTML = `
      <div class="relative max-w-[95vw] max-h-[85vh] sm:max-w-[90vw] sm:max-h-[90vh] flex items-center justify-center">
        <img src="${imageUrl}" class="max-w-full max-h-full object-contain rounded-[1.5rem] sm:rounded-[2rem] shadow-[0_25px_70px_rgba(0,0,0,0.8)] border border-white/10 select-none animate-scale-in">
        <button class="absolute -top-14 right-2 sm:right-0 w-10 h-10 rounded-full bg-white/10 border border-white/10 backdrop-blur text-white flex items-center justify-center hover:bg-white/20 active:scale-90 hover:scale-105 transition-all duration-300 cursor-pointer">
          <i class="fa-solid fa-xmark text-lg"></i>
        </button>
      </div>
    `

    lightbox.onclick = (e) => {
      lightbox.classList.add('animate-fade-out')
      setTimeout(() => {
        lightbox.remove()
        document.body.style.overflow = ''
      }, 200)
    }

    document.body.appendChild(lightbox)
    document.body.style.overflow = 'hidden'
  }
}
