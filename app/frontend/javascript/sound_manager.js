export class SoundManager {
  static #audioCtx = null

  static get ctx() {
    if (!this.#audioCtx) {
      this.#audioCtx = new (window.AudioContext || window.webkitAudioContext)()
    }
    return this.#audioCtx
  }

  static async play(type) {
    if (this.ctx.state === "suspended") {
      try {
        await this.ctx.resume()
      } catch (e) {
        console.warn("Audio context could not be resumed:", e)
        return
      }
    }

    switch (type) {
      case "success":
        this.#playSuccess()
        break
      case "error":
        this.#playError()
        break
      case "click":
        this.#playClick()
        break
      case "notification":
        this.#playNotification()
        break
    }
  }

  static #playNotification() {
    const osc = this.ctx.createOscillator()
    const gain = this.ctx.createGain()

    osc.type = "sine"
    osc.frequency.setValueAtTime(880, this.ctx.currentTime) // A5
    osc.frequency.exponentialRampToValueAtTime(1320, this.ctx.currentTime + 0.1) // E6

    gain.gain.setValueAtTime(0, this.ctx.currentTime)
    gain.gain.linearRampToValueAtTime(0.1, this.ctx.currentTime + 0.02)
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.2)

    osc.connect(gain)
    gain.connect(this.ctx.destination)

    osc.start()
    osc.stop(this.ctx.currentTime + 0.2)
  }

  static #playSuccess() {
    const osc = this.ctx.createOscillator()
    const gain = this.ctx.createGain()

    osc.type = "sine"
    osc.frequency.setValueAtTime(523.25, this.ctx.currentTime) // C5
    osc.frequency.exponentialRampToValueAtTime(783.99, this.ctx.currentTime + 0.1) // G5

    gain.gain.setValueAtTime(0, this.ctx.currentTime)
    gain.gain.linearRampToValueAtTime(0.15, this.ctx.currentTime + 0.05)
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.4)

    osc.connect(gain)
    gain.connect(this.ctx.destination)

    osc.start()
    osc.stop(this.ctx.currentTime + 0.3)
  }

  static #playError() {
    const osc = this.ctx.createOscillator()
    const gain = this.ctx.createGain()

    osc.type = "triangle"
    osc.frequency.setValueAtTime(110, this.ctx.currentTime)
    osc.frequency.linearRampToValueAtTime(73.42, this.ctx.currentTime + 0.2)

    gain.gain.setValueAtTime(0, this.ctx.currentTime)
    gain.gain.linearRampToValueAtTime(0.1, this.ctx.currentTime + 0.05)
    gain.gain.linearRampToValueAtTime(0, this.ctx.currentTime + 0.4)

    osc.connect(gain)
    gain.connect(this.ctx.destination)

    osc.start()
    osc.stop(this.ctx.currentTime + 0.4)
  }

  static #playClick() {
    const osc = this.ctx.createOscillator()
    const gain = this.ctx.createGain()

    osc.type = "sine"
    osc.frequency.setValueAtTime(1200, this.ctx.currentTime)

    gain.gain.setValueAtTime(0, this.ctx.currentTime)
    gain.gain.linearRampToValueAtTime(0.05, this.ctx.currentTime + 0.01)
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.05)

    osc.connect(gain)
    gain.connect(this.ctx.destination)

    osc.start()
    osc.stop(this.ctx.currentTime + 0.05)
  }
}
