import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { default: String }

  connect() {
    const defaultTab = this.defaultValue || this.tabTargets[0].dataset.tab
    this.activateTab(defaultTab)
  }

  switch(event) {
    const tabName = event.currentTarget.dataset.tab
    this.activateTab(tabName)
  }

  activateTab(tabName) {
    // Actualizar Botones
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tab === tabName) {
        tab.classList.add("tab-active")
        tab.classList.remove("text-gray-400", "dark:text-slate-500", "hover:text-indigo-600", "dark:hover:text-indigo-400")
      } else {
        tab.classList.remove("tab-active")
        tab.classList.add("text-gray-400", "dark:text-slate-500", "hover:text-indigo-600", "dark:hover:text-indigo-400")
      }
    })

    // Actualizar Paneles
    this.panelTargets.forEach(panel => {
      if (panel.dataset.panel === tabName) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })

    // Dispatch resize for fullcalendar just in case
    window.dispatchEvent(new Event('resize'))
  }
}
