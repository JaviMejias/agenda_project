import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { default: String }

  connect() {
    this.switch({ currentTarget: this.tabTargets.find(t => t.dataset.tab === this.defaultValue) || this.tabTargets[0] })
  }

  switch(event) {
    const selectedTab = event.currentTarget
    const tabName = selectedTab.dataset.tab

    
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tab === tabName) {
        tab.classList.add("bg-white", "text-indigo-600", "shadow-sm")
        tab.classList.remove("text-gray-500", "hover:bg-gray-200/50")
      } else {
        tab.classList.remove("bg-white", "text-indigo-600", "shadow-sm")
        tab.classList.add("text-gray-500", "hover:bg-gray-200/50")
      }
    })

    
    this.panelTargets.forEach(panel => {
      if (panel.dataset.panel === tabName) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }
}
