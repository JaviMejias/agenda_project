import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "input", "results", "container"]

  connect() {
    this.boundKeydown = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.boundKeydown)
    this.selectedIndex = -1
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundKeydown)
  }

  handleKeydown(e) {
    // Cmd+K or Ctrl+K to open
    if ((e.metaKey || e.ctrlKey) && e.key === "k") {
      e.preventDefault()
      this.open()
    }

    // Esc to close
    if (e.key === "Escape" && !this.modalTarget.classList.contains("hidden")) {
      this.close()
    }

    // Navigation in results
    if (!this.modalTarget.classList.contains("hidden")) {
      if (e.key === "ArrowDown") {
        e.preventDefault()
        this.navigate(1)
      } else if (e.key === "ArrowUp") {
        e.preventDefault()
        this.navigate(-1)
      } else if (e.key === "Enter" && this.selectedIndex !== -1) {
        e.preventDefault()
        this.selectCurrent()
      }
    }
  }

  open() {
    this.modalTarget.classList.remove("hidden")
    // Trigger animation
    setTimeout(() => {
      this.containerTarget.classList.remove("scale-95", "opacity-0")
      this.containerTarget.classList.add("scale-100", "opacity-100")
      this.inputTarget.focus()
    }, 10)
  }

  close() {
    this.containerTarget.classList.remove("scale-100", "opacity-100")
    this.containerTarget.classList.add("scale-95", "opacity-0")
    setTimeout(() => {
      this.modalTarget.classList.add("hidden")
      this.inputTarget.value = ""
      this.resultsTarget.innerHTML = ""
      this.selectedIndex = -1
    }, 200)
  }

  async search() {
    const query = this.inputTarget.value.trim()
    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      this.selectedIndex = -1
      return
    }

    try {
      const response = await fetch(`/search?q=${encodeURIComponent(query)}`)
      const data = await response.json()
      this.renderResults(data.results)
    } catch (error) {
      console.error("Search error:", error)
    }
  }

  renderResults(results) {
    if (results.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="p-8 text-center">
          <i class="fa-solid fa-magnifying-glass text-gray-300 text-3xl mb-3 block"></i>
          <p class="text-sm text-gray-500 font-medium">No se encontraron resultados</p>
        </div>
      `
      return
    }

    let currentCategory = ""
    let html = ""

    results.forEach((result, index) => {
      if (result.category !== currentCategory) {
        currentCategory = result.category
        html += `<div class="px-4 py-2 text-[10px] font-black text-indigo-600 dark:text-indigo-400 uppercase tracking-widest bg-gray-50/50 dark:bg-slate-800/50 mt-2 first:mt-0">${currentCategory}</div>`
      }

      html += `
        <a href="${result.url}" 
           data-search-index="${index}"
           class="flex items-center gap-4 px-4 py-3 hover:bg-indigo-50 dark:hover:bg-indigo-900/30 transition-colors group">
          <div class="w-8 h-8 rounded-lg bg-white dark:bg-slate-800 border border-gray-100 dark:border-slate-700 flex items-center justify-center text-gray-400 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 shadow-sm transition-all">
            <i class="fa-solid ${result.icon} text-xs"></i>
          </div>
          <div class="flex-grow min-w-0">
            <p class="text-sm font-bold text-gray-900 dark:text-white truncate">${result.title}</p>
            <p class="text-[10px] text-gray-500 dark:text-slate-500 font-medium truncate">${result.subtitle}</p>
          </div>
          <div class="text-gray-300 group-hover:translate-x-1 transition-transform">
            <i class="fa-solid fa-chevron-right text-[10px]"></i>
          </div>
        </a>
      `
    })

    this.resultsTarget.innerHTML = html
    this.selectedIndex = -1
  }

  navigate(direction) {
    const items = this.resultsTarget.querySelectorAll("a")
    if (items.length === 0) return

    this.selectedIndex += direction

    if (this.selectedIndex < 0) this.selectedIndex = items.length - 1
    if (this.selectedIndex >= items.length) this.selectedIndex = 0

    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add("bg-indigo-50", "dark:bg-indigo-900/40")
        item.scrollIntoView({ block: "nearest" })
      } else {
        item.classList.remove("bg-indigo-50", "dark:bg-indigo-900/40")
      }
    })
  }

  selectCurrent() {
    const items = this.resultsTarget.querySelectorAll("a")
    if (this.selectedIndex !== -1 && items[this.selectedIndex]) {
      items[this.selectedIndex].click()
    }
  }
}
