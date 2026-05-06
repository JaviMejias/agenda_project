import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.applyTheme()
  }

  toggle() {
    if (document.documentElement.classList.contains("dark")) {
      this.setLightTheme()
    } else {
      this.setDarkTheme()
    }
  }

  setDarkTheme() {
    document.documentElement.classList.add("dark")
    localStorage.setItem("theme", "dark")
  }

  setLightTheme() {
    document.documentElement.classList.remove("dark")
    localStorage.setItem("theme", "light")
  }

  applyTheme() {
    const savedTheme = localStorage.getItem("theme")
    const systemPrefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches

    if (savedTheme === "dark" || (!savedTheme && systemPrefersDark)) {
      this.setDarkTheme()
    } else {
      this.setLightTheme()
    }
  }
}
