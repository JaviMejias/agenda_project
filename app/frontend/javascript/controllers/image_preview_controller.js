import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "previewContainer"]

  previewImages(event) {
    this.previewContainerTarget.innerHTML = ""

    const files = event.target.files

    if (files) {
      Array.from(files).forEach(file => {
        const wrapper = document.createElement("div")
        wrapper.classList.add("relative", "inline-block", "mr-2", "mb-2")

        if (file.type.startsWith('image/')) {
          const img = document.createElement("img")
          img.src = URL.createObjectURL(file)
          img.onload = () => URL.revokeObjectURL(img.src) 
          img.classList.add("w-32", "h-32", "object-cover", "rounded-2xl", "border", "border-gray-100", "dark:border-slate-800", "shadow-md", "cursor-zoom-in")
          img.setAttribute("data-controller", "lightbox")
          img.setAttribute("data-action", "click->lightbox#open")
          wrapper.appendChild(img)
        } else {
          // Document / PDF / non-image preview card
          const card = document.createElement("div")
          card.classList.add("flex", "flex-col", "items-center", "justify-center", "w-32", "h-32", "bg-indigo-50/50", "dark:bg-indigo-950/20", "rounded-2xl", "border", "border-dashed", "border-indigo-200", "dark:border-indigo-900/50", "p-2", "text-center")
          
          const icon = document.createElement("i")
          if (file.type === 'application/pdf') {
            icon.className = "fa-solid fa-file-pdf text-3xl text-rose-500 mb-1.5"
          } else {
            icon.className = "fa-solid fa-file text-3xl text-indigo-500 mb-1.5"
          }
          
          const nameSpan = document.createElement("p")
          nameSpan.className = "text-[9px] font-black text-gray-700 dark:text-slate-300 truncate w-full px-1 mb-0.5"
          nameSpan.textContent = file.name

          const sizeSpan = document.createElement("span")
          sizeSpan.className = "text-[8px] font-bold text-gray-400 dark:text-slate-500"
          sizeSpan.textContent = this.formatBytes(file.size)

          card.appendChild(icon)
          card.appendChild(nameSpan)
          card.appendChild(sizeSpan)
          wrapper.appendChild(card)
        }

        this.previewContainerTarget.appendChild(wrapper)
      })
    }
  }

  formatBytes(bytes, decimals = 1) {
    if (bytes === 0) return '0 B'
    const k = 1024
    const dm = decimals < 0 ? 0 : decimals
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]
  }
}
