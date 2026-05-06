import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"
import { Spanish } from "flatpickr/dist/l10n/es.js"

export default class extends Controller {
  connect() {
    this.fp = flatpickr(this.element, {
      locale: Spanish,
      dateFormat: "Y-m-d",
      altInput: true,
      altFormat: "d/m/Y",
      disableMobile: true,
      allowInput: true,
      position: "auto center"
    })
  }

  disconnect() {
    if (this.fp) this.fp.destroy()
  }
}
