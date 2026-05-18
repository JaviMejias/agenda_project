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
        option: (item, escape) => {
          const rut = item.rut ? `<div class="text-[10px] text-gray-500 uppercase tracking-widest">${escape(item.rut)}</div>` : ''
          return `<div class="py-2 px-3">
                    <div class="font-bold text-gray-900">${escape(item.name)}</div>
                    ${rut}
                  </div>`
        },
        item: (item, escape) => {
          const rut = item.rut ? `<span class="text-xs font-normal text-gray-400">(${escape(item.rut)})</span>` : ''
          return `<div class="font-bold">${escape(item.name)} ${rut}</div>`
        }
      },
      placeholder: 'Busca o selecciona un cliente...',
      allowEmptyOption: false,
      maxItems: 1,
    }

    this.control = new TomSelect(this.selectTarget, this.settings)

    const selectedOption = this.selectTarget.options[this.selectTarget.selectedIndex]
    if (selectedOption && selectedOption.value) {
      const data = selectedOption.dataset.data ? JSON.parse(selectedOption.dataset.data) : {}
      if (data.rut || selectedOption.dataset.rut) {
        this.control.updateOption(selectedOption.value, {
          id: selectedOption.value,
          name: data.name || selectedOption.text.split('(')[0].trim(),
          rut: data.rut || selectedOption.dataset.rut
        })
      }
    }

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
