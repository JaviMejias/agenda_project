import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "counter"]
  static values = { index: Number }

  connect() {
    this.showCurrentSlide()
  }

  next(event) {
    event.preventDefault()
    event.stopPropagation()
    this.indexValue = (this.indexValue + 1) % this.slideTargets.length
    this.showCurrentSlide()
  }

  previous(event) {
    event.preventDefault()
    event.stopPropagation()
    this.indexValue = (this.indexValue - 1 + this.slideTargets.length) % this.slideTargets.length
    this.showCurrentSlide()
  }

  showCurrentSlide() {
    this.slideTargets.forEach((element, index) => {
      element.classList.toggle("hidden", index !== this.indexValue)
      element.classList.toggle("animate-fade-in", index === this.indexValue)
    })

    if (this.hasCounterTarget) {
      this.counterTarget.innerText = this.indexValue + 1
    }
  }
}
