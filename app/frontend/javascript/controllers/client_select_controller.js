import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"
import "tom-select/dist/css/tom-select.css"

export default class extends Controller {
  static targets = ["select"]
  static values = {
    url: String
  }

  connect() {
    this.settings = {
      valueField: 'id',
      labelField: 'name',
      searchField: ['name', 'rut'],
      load: (query, callback) => {
        const url = `${this.urlValue}?q=${encodeURIComponent(query)}`
        fetch(url)
          .then(response => response.json())
          .then(json => {
            callback(json)
          }).catch(() => {
            callback()
          })
      },
      render: {
        option: function(item, escape) {
          return `<div class="py-2 px-3">
                    <div class="font-bold text-gray-900">${escape(item.name)}</div>
                    <div class="text-[10px] text-gray-500 uppercase tracking-widest">${escape(item.rut)}</div>
                  </div>`
        },
        item: function(item, escape) {
          return `<div class="font-bold">${escape(item.name)} <span class="text-xs font-normal text-gray-400">(${escape(item.rut)})</span></div>`
        }
      },
      placeholder: 'Busca o selecciona un cliente...',
      allowEmptyOption: false,
      maxItems: 1,
    }

    this.control = new TomSelect(this.selectTarget, this.settings)
    
    // Load initial 20 clients when focused if empty
    this.control.on('focus', () => {
      if (this.control.items.length === 0 && Object.keys(this.control.options).length === 0) {
        this.control.load('')
      }
    })
  }

  disconnect() {
    if (this.control) {
      this.control.destroy()
    }
  }
}
