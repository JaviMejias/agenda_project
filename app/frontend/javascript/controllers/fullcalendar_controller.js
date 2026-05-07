import { Controller } from "@hotwired/stimulus"
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'
import esLocale from '@fullcalendar/core/locales/es'

export default class extends Controller {
  static targets = ["calendar", "startInput", "endInput", "preview", "inicio", "fin", "title", "jumpInput", "precioTotal", "calendarView", "submitButton"]
  static values = {
    mode: String,
    eventsUrl: String,
    perHour: Boolean,
    initialStart: String,
    initialEnd: String,
    defaultView: String,
    basePrice: Number
  }

  connect() {
    this.isMobile = window.innerWidth < 640

    if (this.modeValue === 'dashboard') {
      this.initDashboard()
    } else if (this.modeValue === 'booking') {
      this.initBooking()
    }

    this.element.addEventListener("fullcalendar:refetch", () => {
      this.refetch()
    })
  }

  calendarTargetConnected(element) {
    if (this.calendar) {
      this.calendar.destroy()
    }
    if (this.modeValue === 'dashboard') {
      this.initDashboard()
    } else if (this.modeValue === 'booking') {
      this.initBooking()
    }
  }

  refetch() {
    if (this.calendar) {
      this.calendar.refetchEvents()
    }
  }

  initDashboard() {
    const el = this.hasCalendarTarget ? this.calendarTarget : this.element
    
    el.innerHTML = ''
    
    this.calendar = new Calendar(el, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
      initialView: this.defaultViewValue || (this.isMobile ? 'timeGridDay' : 'timeGridWeek'),
      headerToolbar: false, 
      datesSet: (info) => {
        if (this.hasTitleTarget) this.titleTarget.innerText = info.view.title
        this.updateList(info.view.currentStart.toISOString(), info.view.currentEnd.toISOString(), info.view.type)
      },
      locale: esLocale,
      timeZone: 'local',
      buttonIcons: false,
      buttonText: {
        prev: '◀',
        next: '▶'
      },
      slotLabelFormat: {
        hour: '2-digit',
        minute: '2-digit',
        omitZeroMinute: false,
        meridiem: false,
        hour12: false
      },
      eventTimeFormat: {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
      },
      firstDay: 1,
      events: this.eventsUrlValue,
      eventClick: function (info) {
        if (info.event.url) {
          info.jsEvent.preventDefault()
          const Turbo = window.Turbo
          if (Turbo) {
            // Determine origin for back navigation
            const from = this.modeValue === 'booking' ? 'property' : (new URL(window.location).pathname.includes('list') ? 'list' : 'calendar')
            const url = new URL(info.event.url, window.location.origin)
            url.searchParams.set('from', from)
            Turbo.visit(url.toString())
          } else {
            window.location.href = info.event.url
          }
        }
      }
    })
    this.calendar.render()
    
    
    this.updateTabStyles('btn-agenda-header')
    const viewId = this.getViewId(this.calendar.view.type)
    this.updateTabStyles(viewId)

    this.initJumpDatePicker()
  }

  initBooking() {
    const el = this.hasCalendarTarget ? this.calendarTarget : this.element
    
    el.innerHTML = ''
    
    const initialStart = this.initialStartValue ? (this.perHourValue ? this.initialStartValue : this.initialStartValue.substring(0, 10)) : null
    const initialEnd = this.initialEndValue ? (this.perHourValue ? this.initialEndValue : this.initialEndValue.substring(0, 10)) : null

    this.calendar = new Calendar(el, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
      initialView: this.defaultViewValue || (this.perHourValue ? (this.isMobile ? 'timeGridDay' : 'timeGridWeek') : 'dayGridMonth'),
      headerToolbar: false, 
      datesSet: (info) => {
        if (this.hasTitleTarget) this.titleTarget.innerText = info.view.title
        this.updateList(info.view.currentStart.toISOString(), info.view.currentEnd.toISOString(), info.view.type)
      },
      locale: esLocale,
      timeZone: 'local',
      buttonIcons: false,
      buttonText: {
        prev: '◀',
        next: '▶'
      },
      selectable: true,
      selectMirror: true,
      unselectAuto: false,
      longPressDelay: 100,
      eventOverlap: false,
      slotMinTime: '08:00:00',
      slotMaxTime: '22:00:00',
      allDaySlot: false,
      selectAllow: (selectInfo) => {
        const today = new Date()
        today.setHours(0, 0, 0, 0)
        return selectInfo.start >= today
      },
      dayCellClassNames: (arg) => {
        const today = new Date()
        today.setHours(0, 0, 0, 0)
        if (arg.date < today) {
          return ['bg-gray-50/50', 'dark:bg-slate-800/30', 'opacity-60']
        }
        return []
      },
      events: (info, successCallback, failureCallback) => {
        fetch(this.eventsUrlValue)
          .then(response => response.json())
          .then(data => {
            if (initialStart && initialEnd) {
              data.push({
                id: 'ghost-reservation',
                start: initialStart,
                end: initialEnd,
                display: 'block',
                backgroundColor: '#fee2e2',
                borderColor: '#ef4444',
                textColor: '#991b1b',
                title: 'Reserva Actual (Original)',
                classNames: ['border-2', 'border-dashed', 'opacity-60', 'pointer-events-none'],
                editable: false
              })
            }
            successCallback(data)
          })
      },
      eventClick: (info) => {
        if (info.event.url) {
          info.jsEvent.preventDefault()
          const Turbo = window.Turbo
          if (Turbo) {
            const url = new URL(info.event.url, window.location.origin)
            url.searchParams.set('from', 'property')
            Turbo.visit(url.toString())
          } else {
            window.location.href = info.event.url
          }
        }
      },
      select: (info) => {
        let startStr = info.startStr
        let endStr = info.endStr

        
        
        
        if (startStr.length === 10) startStr += 'T00:00:00'
        if (endStr.length === 10) endStr += 'T00:00:00'

        this.startInputTarget.value = startStr
        this.endInputTarget.value = endStr
        this.updatePreview(startStr, endStr)

        
        if (!this.perHourValue) {
          
          const manualEndDate = new Date(endStr.substring(0, 10) + 'T12:00:00')
          manualEndDate.setDate(manualEndDate.getDate() - 1)
          const manualEndStr = manualEndDate.toISOString().substring(0, 10)
          
          if (this.manualStartPicker) this.manualStartPicker.setDate(startStr, false)
          if (this.manualEndPicker) this.manualEndPicker.setDate(manualEndStr, false)
        } else {
          if (this.manualStartPicker) this.manualStartPicker.setDate(startStr, false)
          if (this.manualEndPicker) this.manualEndPicker.setDate(endStr, false)
        }

        if (this.manualStartInput) {
          this.manualStartInput.value = startStr.substring(0, 16)
        }
        if (this.manualEndInput) {
          this.manualEndInput.value = endStr.substring(0, 16)
        }
      }
    })

    this.calendar.render()
    
    
    const viewId = this.getViewId(this.calendar.view.type)
    this.updateTabStyles(viewId)

    this.initJumpDatePicker()

    if (initialStart && initialEnd) {
      // Goto the initial date
      this.calendar.gotoDate(initialStart)
      
      if (!this.startInputTarget.value) this.startInputTarget.value = initialStart
      if (!this.endInputTarget.value) this.endInputTarget.value = initialEnd
      this.updatePreview(this.startInputTarget.value, this.endInputTarget.value)
    }

    this.toggleSubmitButton()

    if (this.isMobile) {
      this.injectManualInputs(el)
    }
  }

  updatePreview(startStr, endStr) {
    if (!this.hasPreviewTarget) return
    this.previewTarget.classList.remove('hidden')

    if (this.hasInicioTarget) this.inicioTarget.innerText = this.formatDateDisplay(startStr)
    if (this.hasFinTarget) this.finTarget.innerText = this.formatDateDisplay(endStr, true)

    if (this.hasPrecioTotalTarget) {
      const price = this.calculatePrice(startStr, endStr)
      const formatter = new Intl.NumberFormat('es-CL', {
        style: 'currency',
        currency: 'CLP',
        minimumFractionDigits: 0
      })
      this.precioTotalTarget.innerText = formatter.format(price)
    }

    this.toggleSubmitButton()
  }

  toggleSubmitButton() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = !(this.startInputTarget.value && this.endInputTarget.value)
    }
  }

  calculatePrice(startStr, endStr) {
    if (!startStr || !endStr) return 0
    const start = new Date(startStr)
    const end = new Date(endStr)
    const basePrice = this.basePriceValue

    if (this.perHourValue) {
      const diffMs = end - start
      const diffHours = Math.ceil(diffMs / (1000 * 60 * 60))
      return Math.max(1, diffHours) * basePrice
    } else {
      const diffMs = end - start
      const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24))
      return Math.max(1, diffDays) * basePrice
    }
  }

  
  injectManualInputs(calendarEl) {
    const container = calendarEl.parentElement
    if (!container) return

    const wrapper = document.createElement('div')
    wrapper.className = 'mt-4 p-4 bg-indigo-50 dark:bg-indigo-950/20 border border-indigo-200 dark:border-indigo-900 rounded-xl space-y-3'

    const title = document.createElement('p')
    title.className = 'text-xs font-bold text-indigo-700 dark:text-indigo-400 uppercase tracking-wider'
    title.innerHTML = '<i class="fa-solid fa-hand-pointer mr-1"></i> Selección manual'

    const inputType = this.perHourValue ? 'datetime-local' : 'date'
    const grid = document.createElement('div')
    grid.className = 'grid grid-cols-2 gap-3'

    
    const startWrap = document.createElement('div')
    const startLabel = document.createElement('label')
    startLabel.className = 'block text-xs font-semibold text-gray-600 dark:text-slate-400 mb-1'
    startLabel.textContent = 'Desde'
    this.manualStartInput = document.createElement('input')
    this.manualStartInput.type = 'text' 
    this.manualStartInput.placeholder = 'Seleccionar...'
    this.manualStartInput.className = 'w-full px-3 py-2.5 border border-gray-200 dark:border-slate-700 rounded-lg text-sm bg-white dark:bg-slate-800 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 cursor-pointer'
    startWrap.appendChild(startLabel)
    startWrap.appendChild(this.manualStartInput)

    
    const endWrap = document.createElement('div')
    const endLabel = document.createElement('label')
    endLabel.className = 'block text-xs font-semibold text-gray-600 dark:text-slate-400 mb-1'
    endLabel.textContent = 'Hasta'
    this.manualEndInput = document.createElement('input')
    this.manualEndInput.type = 'text' 
    this.manualEndInput.placeholder = 'Seleccionar...'
    this.manualEndInput.className = 'w-full px-3 py-2.5 border border-gray-200 dark:border-slate-700 rounded-lg text-sm bg-white dark:bg-slate-800 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 cursor-pointer'
    endWrap.appendChild(endLabel)
    endWrap.appendChild(this.manualEndInput)

    grid.appendChild(startWrap)
    grid.appendChild(endWrap)

    
    Promise.all([
      import('flatpickr'),
      import('flatpickr/dist/l10n/es.js')
    ]).then(([fpModule, locModule]) => {
      const flatpickr = fpModule.default
      const esLocale = locModule.default.es || locModule.Spanish
      
      const config = {
        locale: esLocale,
        enableTime: this.perHourValue,
        dateFormat: this.perHourValue ? 'Y-m-d H:i' : 'Y-m-d',
        altInput: true,
        altFormat: this.perHourValue ? 'd/m/Y H:i' : 'd/m/Y',
        disableMobile: true,
        allowInput: true,
        minDate: 'today',
        position: 'auto center',
        onChange: (selectedDates, dateStr) => {
          let startVal = this.manualStartInput.value
          let endVal = this.manualEndInput.value

          if (startVal && endVal) {
            try {
              
              let finalEndVal = endVal
              if (!this.perHourValue) {
                
                const cleanEnd = endVal.substring(0, 10)
                const endDate = new Date(cleanEnd + 'T12:00:00')
                
                if (!isNaN(endDate.getTime())) {
                  endDate.setDate(endDate.getDate() + 1)
                  finalEndVal = endDate.toISOString().substring(0, 10) + 'T00:00:00'
                }
                
                if (startVal.length === 10) startVal += 'T00:00:00'
              }

              this.startInputTarget.value = startVal
              this.endInputTarget.value = finalEndVal
              this.updatePreview(startVal, finalEndVal)

              
              this.calendar.gotoDate(startVal)
              this.calendar.select(startVal, finalEndVal)
            } catch (e) {
              console.error("Error sync manual dates:", e)
            }
          }
        }
      }

      this.manualStartPicker = flatpickr(this.manualStartInput, config)
      this.manualEndPicker = flatpickr(this.manualEndInput, config)
    })

    
    if (this.hasInitialStartValue && this.initialStartValue) {
      const val = this.initialStartValue.substring(0, 16) || this.initialStartValue.substring(0, 10)
      this.manualStartInput.value = val
    }
    if (this.hasInitialEndValue && this.initialEndValue) {
      const val = this.initialEndValue.substring(0, 16) || this.initialEndValue.substring(0, 10)
      this.manualEndInput.value = val
    }

    wrapper.appendChild(title)
    wrapper.appendChild(grid)
    
    container.insertBefore(wrapper, container.firstChild)
  }

  
  formatDateDisplay(dateStr, isEnd = false) {
    if (!dateStr) return "---"
    
    
    let date
    if (dateStr.includes('T')) {
      date = new Date(dateStr)
    } else {
      
      const [year, month, day] = dateStr.split('-').map(Number)
      date = new Date(year, month - 1, day)
    }
    
    if (isNaN(date.getTime())) return "Fecha inválida"

    
    if (!this.perHourValue && isEnd) {
      date.setDate(date.getDate() - 1)
    }

    const options = {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    }

    if (this.perHourValue) {
      options.month = 'long'
      options.hour = '2-digit'
      options.minute = '2-digit'
      return date.toLocaleString('es-CL', options)
    }

    return date.toLocaleDateString('es-CL', options)
  }



  prev() {
    this.calendar.prev()
  }

  next() {
    this.calendar.next()
  }

  today() {
    this.calendar.today()
  }

  initJumpDatePicker() {
    if (!this.hasJumpInputTarget) return

    Promise.all([
      import('flatpickr'),
      import('flatpickr/dist/l10n/es.js')
    ]).then(([fpModule, locModule]) => {
      const flatpickr = fpModule.default
      const esLocale = locModule.default.es || locModule.Spanish

      this.jumpFp = flatpickr(this.jumpInputTarget, {
        dateFormat: 'Y-m-d',
        locale: esLocale,
        disableMobile: true,
        monthSelectorType: 'static',
        yearSelectorType: 'static',
        static: true, 
        onChange: (selectedDates) => {
          if (selectedDates.length > 0 && this.calendar) {
            this.calendar.gotoDate(selectedDates[0])
          }
        }
      })
    })
  }

  openDatePicker() {
    if (this.jumpFp) {
      this.jumpFp.open()
    }
  }

  changeView(event) {
    const view = event.currentTarget.dataset.view
    this.calendar.changeView(view)
    
    if (this.hasCalendarViewTarget) this.calendarViewTarget.classList.remove('view-hidden')
    if (this.hasListViewTarget) this.listViewTarget.classList.add('view-hidden')
    
    const calHeader = document.getElementById('calendar-header-container')
    if (calHeader) calHeader.classList.remove('hidden')
    
    this.updateTabStyles(event.currentTarget.id)

    
    this._setViewParam('')
  }

  showList(event) {
    
  }

  
  _setViewParam(value) {
    const url = new URL(window.location)
    if (value) {
      url.searchParams.set('view', value)
    } else {
      url.searchParams.delete('view')
    }
    window.history.replaceState({}, '', url)
  }

  getViewId(viewType) {
    switch(viewType) {
      case 'dayGridMonth': return this.modeValue === 'dashboard' ? 'btn-month' : 'btn-month-cal'
      case 'timeGridWeek': return this.modeValue === 'dashboard' ? 'btn-week' : 'btn-week-cal'
      case 'timeGridDay': return this.modeValue === 'dashboard' ? 'btn-day' : 'btn-day-cal'
      default: return null
    }
  }

  updateTabStyles(activeId) {
    const ids = [
      'btn-month', 'btn-week', 'btn-day', 'btn-list', 
      'btn-month-cal', 'btn-week-cal', 'btn-day-cal',
      'btn-agenda-header', 'btn-list-header'
    ]
    
    ids.forEach(id => {
      const btn = document.getElementById(id)
      if (!btn) return

      if (id === activeId) {
        btn.classList.add('tab-active')
      } else {
        
        
        const isHeaderBtn = id === 'btn-agenda-header' || id === 'btn-list-header'
        const activatingCalendarView = activeId && (activeId.includes('month') || activeId.includes('week') || activeId.includes('day'))
        
        if (id === 'btn-agenda-header' && activatingCalendarView) {
          
        } else {
          btn.classList.remove('tab-active')
        }
      }
    })
  }

  updateList(start, end, viewType = '') {
    if (this.modeValue !== 'dashboard') return
    
    const frame = document.getElementById('reservations_list_frame')
    if (frame) {
      frame.src = `/reservations/calendar_list?start=${encodeURIComponent(start)}&end=${encodeURIComponent(end)}&view_type=${viewType}`
    }
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy()
    }
    if (this.jumpFp) {
      this.jumpFp.destroy()
    }
    if (this.manualStartPicker) this.manualStartPicker.destroy()
    if (this.manualEndPicker) this.manualEndPicker.destroy()
  }
}
