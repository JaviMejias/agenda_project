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
    setTimeout(() => this.renderCharts(), 100)
  }

  statusDataValueChanged() {
    setTimeout(() => this.renderStatusChart(), 100)
  }

  revenueDatasetsValueChanged() {
    setTimeout(() => this.renderRevenueChart(), 100)
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
    const map = { pending: '#f59e0b', confirmed: '#10b981', cancelled: '#ef4444' }
    const colors = Object.keys(data).map(k => map[k] || '#6366f1')

    this.statusChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: labels,
        datasets: [{
          data: Object.values(data).map(() => 0),
          backgroundColor: colors,
          borderWidth: 0
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: {
          duration: 2000,
          animateRotate: true,
          animateScale: true
        }
      }
    })

    setTimeout(() => {
      this.statusChart.data.datasets[0].data = Object.values(data)
      this.statusChart.update()
    }, 100)
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
        datasets: datasets.map(ds => ({ ...ds, data: ds.data.map(() => 0) }))
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: {
          duration: 2000,
          easing: 'easeOutQuart'
        },
        scales: {
          y: { beginAtZero: true }
        }
      }
    })

    setTimeout(() => {
      this.revenueChart.data.datasets.forEach((ds, i) => {
        ds.data = datasets[i].data
      })
      this.revenueChart.update()
    }, 150)
  }

  disconnect() {
    if (this.statusChart) this.statusChart.destroy()
    if (this.revenueChart) this.revenueChart.destroy()
  }
}
