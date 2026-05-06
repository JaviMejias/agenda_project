import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "previewContainer"]


  previewImages(event) {
    this.previewContainerTarget.innerHTML = ""

    const files = event.target.files

    if (files) {
      Array.from(files).forEach(file => {
        if (!file.type.startsWith('image/')) return

        const img = document.createElement("img")
        img.src = URL.createObjectURL(file)
        img.onload = () => URL.revokeObjectURL(img.src) 
        img.classList.add("w-32", "h-32", "object-cover", "rounded-md", "border", "border-gray-200", "shadow-sm")

        const wrapper = document.createElement("div")
        wrapper.classList.add("relative", "inline-block", "mr-4", "mb-4")

        wrapper.appendChild(img)
        this.previewContainerTarget.appendChild(wrapper)
      })
    }
  }
}
