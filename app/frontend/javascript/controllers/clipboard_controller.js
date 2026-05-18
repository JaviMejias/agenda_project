import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "icon", "tooltip"]
  static values = { text: String }

  copy(event) {
    event.preventDefault()

    const textToCopy = this.hasTextValue ? this.textValue : (this.hasValueTarget ? this.valueTarget.textContent.trim() : "")

    if (!textToCopy) return

    navigator.clipboard.writeText(textToCopy).then(() => {
      this.showSuccessState()
    }).catch(err => {
      console.error("Failed to copy text: ", err)
    })
  }

  showSuccessState() {
    if (this.hasValueTarget) {
      this.valueTarget.classList.add('text-emerald-600', 'dark:text-emerald-400', 'scale-105')
    }

    if (this.hasIconTarget) {
      this._originalIconClasses = this.iconTarget.getAttribute("class")
      this.iconTarget.setAttribute("class", 'copy-icon fa-solid fa-check text-emerald-500 scale-125')
    }

    if (this.hasTooltipTarget) {
      this.tooltipTarget.classList.remove('opacity-0', 'translate-y-1', 'pointer-events-none')
      this.tooltipTarget.classList.add('opacity-100', '-translate-y-1')
    }

    setTimeout(() => {
      this.resetState()
    }, 1500)
  }

  resetState() {
    if (this.hasValueTarget) {
      this.valueTarget.classList.remove('text-emerald-600', 'dark:text-emerald-400', 'scale-105')
    }

    if (this.hasIconTarget && this._originalIconClasses) {
      this.iconTarget.setAttribute("class", this._originalIconClasses)
    }

    if (this.hasTooltipTarget) {
      this.tooltipTarget.classList.remove('opacity-100', '-translate-y-1')
      this.tooltipTarget.classList.add('opacity-0', 'translate-y-1', 'pointer-events-none')
    }
  }
}
