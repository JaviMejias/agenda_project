import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    event.preventDefault()
    const imageUrl = event.currentTarget.src || event.currentTarget.dataset.url
    if (!imageUrl) return

    const lightbox = document.createElement('div')
    lightbox.id = 'lightbox-modal'
    lightbox.className = 'fixed inset-0 z-[100] bg-black/95 flex items-center justify-center p-4 sm:p-10 cursor-zoom-out animate-fade-in'
    lightbox.innerHTML = `
      <div class="relative max-h-full">
        <img src="${imageUrl}" class="max-w-full max-h-[90vh] object-contain rounded-xl shadow-2xl animate-scale-in">
        <button class="absolute -top-12 right-0 text-white text-3xl hover:text-gray-300 transition-colors">
          <i class="fa-solid fa-xmark"></i>
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
