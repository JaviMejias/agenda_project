import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form", "status", "loading"]
  static values = { delay: { type: Number, default: 400 } }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this._showLoading()
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, this.delayValue)
  }

  submit() {
    this._showLoading()
    this.formTarget.requestSubmit()
  }

  reset() {
    if (this.hasInputTarget) this.inputTarget.value = ""
    if (this.hasStatusTarget) this.statusTarget.value = ""
    this.submit()
  }

  _showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
      this.loadingTarget.classList.add('flex')
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
