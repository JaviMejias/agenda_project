import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'

export default class extends Controller {
  static targets = ["statusChart", "revenueChart"]
  static values = {
    statusData: { type: Object, default: {} },
    revenueDatasets: { type: Array, default: [] },
    labels: { type: Array, default: [] }
  }

  connect() {
    
    if (this.revenueDatasetsValue.length > 0) {
      this.renderCharts()
    }
  }

  
  statusChartTargetConnected() {
    if (Object.keys(this.statusDataValue).length > 0) {
      this.renderStatusChart()
    }
  }

  revenueChartTargetConnected() {
    if (this.revenueDatasetsValue.length > 0) {
      this.renderRevenueChart()
    }
  }

  statusDataValueChanged() {
    this.renderStatusChart()
  }

  revenueDatasetsValueChanged() {
    this.renderRevenueChart()
  }

  renderCharts() {
    this.renderStatusChart()
    this.renderRevenueChart()
  }

  renderStatusChart() {
    if (!this.hasStatusChartTarget) return
    if (this.statusChart) this.statusChart.destroy()

    const ctx = this.statusChartTarget.getContext('2d')
    const data = this.statusDataValue
    
    
    const labels = Object.keys(data).map(k => {
      const translations = { pending: 'Pendiente', confirmed: 'Confirmada', cancelled: 'Cancelada' }
      return translations[k] || k
    })
    const colors = Object.keys(data).map(k => {
      const map = { pending: '#f59e0b', confirmed: '#10b981', cancelled: '#ef4444' }
      return map[k] || '#6366f1'
    })

    this.statusChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: labels,
        datasets: [{
          data: Object.values(data),
          backgroundColor: colors,
          borderWidth: 0,
          hoverOffset: 10
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              usePointStyle: true,
              padding: 20,
              font: { weight: 'bold', size: 10 }
            }
          }
        },
        cutout: '70%'
      }
    })
  }

  renderRevenueChart() {
    if (!this.hasRevenueChartTarget) return
    if (this.revenueChart) this.revenueChart.destroy()

    const ctx = this.revenueChartTarget.getContext('2d')
    const labels = this.labelsValue
    const datasetsRaw = this.revenueDatasetsValue

    const datasets = datasetsRaw.map(ds => {
      
      const gradient = ctx.createLinearGradient(0, 0, 0, 400)
      gradient.addColorStop(0, `${ds.color}33`) 
      gradient.addColorStop(1, `${ds.color}00`) 

      return {
        label: ds.label,
        data: ds.data,
        borderColor: ds.color,
        backgroundColor: gradient,
        borderWidth: 2,
        fill: true,
        tension: 0.4,
        pointBackgroundColor: '#ffffff',
        pointBorderColor: ds.color,
        pointBorderWidth: 1.5,
        pointRadius: 2,
        pointHoverRadius: 5
      }
    })

    this.revenueChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: 'index',
          intersect: false,
        },
        plugins: {
          legend: {
            position: 'top',
            align: 'end',
            labels: {
              usePointStyle: true,
              padding: 15,
              font: { weight: 'bold', size: 10 }
            }
          },
          tooltip: {
            backgroundColor: '#1e1b4b',
            padding: 12,
            titleFont: { size: 14, weight: 'bold' },
            bodyFont: { size: 12 },
            callbacks: {
              label: (context) => `${context.dataset.label}: $${context.parsed.y.toLocaleString('es-CL')}`
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: { color: 'rgba(0, 0, 0, 0.03)' },
            ticks: {
              callback: (value) => '$' + value.toLocaleString('es-CL'),
              font: { size: 10, weight: 'bold' }
            }
          },
          x: {
            grid: { display: false },
            ticks: { font: { size: 10, weight: 'bold' } }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.statusChart) this.statusChart.destroy()
    if (this.revenueChart) this.revenueChart.destroy()
  }
}
