import { Controller } from "@hotwired/stimulus"
import Pickr from "@simonwep/pickr"
import "@simonwep/pickr/dist/themes/classic.min.css"

export default class extends Controller {
  static targets = ["input", "swatch", "picker"]

  connect() {
    this.initPickr()
    this.updateActiveSwatch(this.inputTarget.value)
  }

  initPickr() {
    this.pickr = Pickr.create({
      el: this.pickerTarget,
      theme: 'classic',
      default: this.inputTarget.value || '#4f46e5',
      swatches: null,
      components: {
        preview: true,
        opacity: false,
        hue: true,
        interaction: {
          hex: true,
          input: true,
          clear: false,
          save: true
        }
      },
      i18n: {
        'btn:save': 'Seleccionar',
        'btn:cancel': 'Cancelar'
      }
    })

    this.pickr.on('save', (color) => {
      const hex = color.toHEXA().toString()
      this.inputTarget.value = hex
      this.updateActiveSwatch(hex)
      this.pickr.hide()
    })
  }

  selectColor(event) {
    const color = event.currentTarget.dataset.color
    this.inputTarget.value = color
    this.updateActiveSwatch(color)
    if (this.pickr) this.pickr.setColor(color)
  }

  updateActiveSwatch(selectedColor) {
    const targetColor = (selectedColor || "#4f46e5").toLowerCase()
    this.swatchTargets.forEach(swatch => {
      const swatchColor = swatch.dataset.color.toLowerCase()
      if (swatchColor === targetColor) {
        swatch.classList.add("ring-2", "ring-offset-2", "ring-gray-400", "scale-110")
      } else {
        swatch.classList.remove("ring-2", "ring-offset-2", "ring-gray-400", "scale-110")
      }
    })
  }

  disconnect() {
    if (this.pickr) this.pickr.destroyAndRemove()
  }
}
