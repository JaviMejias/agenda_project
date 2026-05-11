import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["indicator"]

  markAsRead(event) {
    this.element.classList.add("notification-marking-read")
    this.element.classList.remove("bg-indigo-50/30", "dark:bg-indigo-900/20")
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.add("opacity-0", "scale-0")
    }
  }

  remove(event) {
    this.element.classList.add("notification-removing")
    
    // We don't prevent default, the form will still submit
    // The animation is fast enough that it looks good before the turbo-stream removes it
  }
}
