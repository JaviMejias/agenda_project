import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "startDate", "endDate", "loading"]

  connect() {
    this.timeout = null
  }

  submit() {
    clearTimeout(this.timeout)
    
    
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
      this.loadingTarget.classList.add('flex')
    }

    
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 1000)
  }

  reset() {
    const now = new Date()
    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1)
    const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0)

    
    const format = (d) => d.toISOString().split('T')[0]

    
    if (this.startDateTarget._flatpickr) {
      this.startDateTarget._flatpickr.setDate(firstDay)
    } else {
      this.startDateTarget.value = format(firstDay)
    }

    if (this.endDateTarget._flatpickr) {
      this.endDateTarget._flatpickr.setDate(lastDay)
    } else {
      this.endDateTarget.value = format(lastDay)
    }

    this.submit()
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
      this.loadingTarget.classList.remove('flex')
    }
  }
}
