import { Controller } from "@hotwired/stimulus"
import { SoundManager } from "../sound_manager"

export default class extends Controller {
  connect() {
    this.triggerVisualEffects()
    this.playSound()
    this.element.remove()
  }

  triggerVisualEffects() {
    const bell = document.getElementById("notification-bell")
    if (bell) {
      bell.classList.add("animate-wiggle")
      setTimeout(() => {
        bell.classList.remove("animate-wiggle")
      }, 1000)
    }
  }

  playSound() {
    const audioEnabled = localStorage.getItem("notification-sound-enabled") !== "false"
    if (!audioEnabled) return

    SoundManager.play("notification")
  }
}
