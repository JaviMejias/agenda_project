import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lightIcon", "darkIcon", "systemIcon"]

  connect() {
    this.applyTheme()
    this.themeQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.themeQueryListener = () => {
      if (localStorage.getItem("theme") === "system") {
        this.applyTheme()
      }
    }
    this.themeQuery.addEventListener("change", this.themeQueryListener)
  }

  disconnect() {
    if (this.themeQuery && this.themeQueryListener) {
      this.themeQuery.removeEventListener("change", this.themeQueryListener)
    }
  }

  setTheme(event) {
    const theme = event.currentTarget.dataset.themeValue
    localStorage.setItem("theme", theme)
    this.applyTheme()
  }

  applyTheme() {
    const theme = localStorage.getItem("theme") || "dark"
    const systemPrefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const isDark = theme === "dark" || (theme === "system" && systemPrefersDark)

    if (isDark) {
      document.documentElement.classList.add("dark")
      document.documentElement.style.colorScheme = "dark"
    } else {
      document.documentElement.classList.remove("dark")
      document.documentElement.style.colorScheme = "light"
    }

    this.updateUI(theme)
  }

  updateUI(theme) {
    const themes = ["light", "dark", "system"]
    themes.forEach(t => {
      const btn = this.element.querySelector(`[data-theme-value="${t}"]`)
      if (btn) {
        if (t === theme) {
          btn.classList.add("text-indigo-600", "bg-white", "dark:bg-slate-700", "shadow-sm", "ring-1", "ring-black/5")
          btn.classList.remove("text-gray-400", "dark:text-slate-500")
        } else {
          btn.classList.remove("text-indigo-600", "bg-white", "dark:bg-slate-700", "shadow-sm", "ring-1", "ring-black/5")
          btn.classList.add("text-gray-400", "dark:text-slate-500")
        }
      }
    })
  }
}
