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
          const rut = item.rut ? `<div class="text-[10px] text-gray-500 uppercase tracking-widest">${escape(this.formatRut(item.rut))}</div>` : ''
          return `<div class="py-2 px-3">
                    <div class="font-bold text-gray-900">${escape(item.name)}</div>
                    ${rut}
                  </div>`
        },
        item: (item, escape) => {
          const rut = item.rut ? `<span class="text-xs font-normal text-gray-400">(${escape(this.formatRut(item.rut))})</span>` : ''
          return `<div class="font-bold">${escape(item.name)} ${rut}</div>`
        }
      },
      placeholder: 'Busca o selecciona un cliente...',
      allowEmptyOption: false,
      maxItems: 1,
    }

    this.control = new TomSelect(this.selectTarget, this.settings)
    
    // Si ya hay una opción seleccionada, asegurarnos de que tenga los datos necesarios
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
    
    // Load initial 20 clients when focused if empty
    this.control.on('focus', () => {
      if (this.control.items.length === 0 && Object.keys(this.control.options).length === 0) {
        this.control.load('')
      }
    })
  }

  formatRut(rut) {
    if (!rut) return ""
    // Limpiar el rut de puntos y guiones previos
    let value = rut.toString().replace(/[^0-9kK]/g, '')
    if (value.length < 2) return value

    let cuerpo = value.slice(0, -1)
    let dv = value.slice(-1).toUpperCase()

    let result = ''
    let j = 0
    for (let i = cuerpo.length - 1; i >= 0; i--) {
      result = cuerpo.charAt(i) + result
      j++
      if (j % 3 === 0 && i !== 0) {
        result = '.' + result
      }
    }
    return result + '-' + dv
  }

  disconnect() {
    if (this.control) {
      this.control.destroy()
    }
  }
}
