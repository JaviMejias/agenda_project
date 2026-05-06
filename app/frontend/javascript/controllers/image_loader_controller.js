import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "placeholder"]

  connect() {
    if (this.imageTarget.complete) {
      this.showImage()
    }
  }

  load() {
    this.showImage()
  }

  showImage() {
    this.placeholderTarget.classList.add("hidden")
    this.imageTarget.classList.remove("opacity-0")
    this.imageTarget.classList.add("opacity-100")
  }
}
