import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'

export default class extends Controller {
  static targets = ["incomeChart", "occupancyChart"]
  static values = {
    properties: Array,
    trend: Array
  }

  connect() {
    setTimeout(() => this.renderCharts(), 100)
  }

  propertiesValueChanged() {
    setTimeout(() => this.renderCharts(), 50)
  }

  renderCharts() {
    this.renderIncomeChart()
    this.renderOccupancyChart()
  }

  renderIncomeChart() {
    if (!this.hasIncomeChartTarget) return
    if (this.incomeChart) this.incomeChart.destroy()

    const activeProperties = this.propertiesValue.filter(p => p.income > 0)

    if (activeProperties.length === 0) {
      return
    }

    const ctx = this.incomeChartTarget.getContext('2d')
    const labels = activeProperties.map(p => p.name)
    const data = activeProperties.map(p => p.income)
    const colors = activeProperties.map(p => p.color)

    this.incomeChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Ingresos ($)',
          data: data.map(() => 0),
          backgroundColor: colors,
          borderRadius: 8,
          borderWidth: 0,
          barThickness: 30
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          y: { beginAtZero: true }
        },
        animation: {
          duration: 2000,
          easing: 'easeOutQuart'
        }
      }
    })

    setTimeout(() => {
      this.incomeChart.data.datasets[0].data = data
      this.incomeChart.update()
    }, 150)
  }

  renderOccupancyChart() {
    if (!this.hasOccupancyChartTarget) return
    if (this.occupancyChart) this.occupancyChart.destroy()

    const activeProperties = this.propertiesValue.filter(p => p.occupancy_rate > 0)

    if (activeProperties.length === 0) return

    const ctx = this.occupancyChartTarget.getContext('2d')
    const labels = activeProperties.map(p => p.name)
    const data = activeProperties.map(p => p.occupancy_rate)
    const colors = activeProperties.map(p => p.color)

    this.occupancyChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: labels,
        datasets: [{
          data: data.map(() => 0),
          backgroundColor: colors,
          borderWidth: 0
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '70%',
        animation: {
          animateRotate: true,
          animateScale: true,
          duration: 1500,
          easing: 'easeOutQuart'
        }
      }
    })

    setTimeout(() => {
      this.occupancyChart.data.datasets[0].data = data
      this.occupancyChart.update()
    }, 150)
  }

  disconnect() {
    if (this.incomeChart) this.incomeChart.destroy()
    if (this.occupancyChart) this.occupancyChart.destroy()
  }
}
