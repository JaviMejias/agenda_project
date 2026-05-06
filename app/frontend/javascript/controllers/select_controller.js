import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"
import "tom-select/dist/css/tom-select.css"

export default class extends Controller {
  static values = {
    placeholder: { type: String, default: "Selecciona una opción..." },
    url: String
  }

  connect() {
    const config = {
      placeholder: this.placeholderValue,
      plugins: ['remove_button'],
      render: {
        no_results: function(data, escape) {
          return '<div class="no-results py-2 px-3 text-xs text-gray-500 italic">No se encontraron resultados para "' + escape(data.input) + '"</div>';
        }
      }
    }

    if (this.urlValue) {
      config.valueField = 'id'
      config.labelField = 'name'
      config.searchField = 'name'
      config.load = (query, callback) => {
        const url = `${this.urlValue}?q=${encodeURIComponent(query)}`
        fetch(url)
          .then(response => response.json())
          .then(json => {
            callback(json)
          }).catch(() => {
            callback()
          })
      }
    }

    this.control = new TomSelect(this.element, config)

    if (this.urlValue) {
      this.control.on('focus', () => {
        if (this.control.items.length === 0 && Object.keys(this.control.options).length === 0) {
          this.control.load('')
        }
      })
    }
  }

  disconnect() {
    if (this.control) {
      this.control.destroy()
    }
  }
}
