import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.selectTab(this.tabTargets[0])
  }

  switch(event) {
    event.preventDefault()
    this.selectTab(event.currentTarget)
  }

  selectTab(selectedTab) {
    // Determine target panel
    const targetPanelId = selectedTab.dataset.target

    // Update tabs
    this.tabTargets.forEach(tab => {
      if (tab === selectedTab) {
        tab.classList.add("bg-indigo-50", "dark:bg-indigo-900/30", "text-indigo-600", "dark:text-indigo-400", "border-indigo-200", "dark:border-indigo-800")
        tab.classList.remove("bg-white", "dark:bg-slate-900", "text-gray-500", "dark:text-slate-400", "border-gray-200", "dark:border-slate-800", "hover:bg-gray-50", "dark:hover:bg-slate-800/50")
      } else {
        tab.classList.remove("bg-indigo-50", "dark:bg-indigo-900/30", "text-indigo-600", "dark:text-indigo-400", "border-indigo-200", "dark:border-indigo-800")
        tab.classList.add("bg-white", "dark:bg-slate-900", "text-gray-500", "dark:text-slate-400", "border-gray-200", "dark:border-slate-800", "hover:bg-gray-50", "dark:hover:bg-slate-800/50")
      }
    })

    // Update panels
    this.panelTargets.forEach(panel => {
      if (panel.id === targetPanelId) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }
}
