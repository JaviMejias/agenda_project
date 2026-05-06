import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'

export default class extends Controller {
  static targets = ["incomeChart", "occupancyChart"]
  static values = {
    properties: Array,
    trend: Array
  }

  connect() {
    this.renderCharts()
  }

  incomeChartTargetConnected() {
    this.renderIncomeChart()
  }

  occupancyChartTargetConnected() {
    this.renderOccupancyChart()
  }

  propertiesValueChanged() {
    this.renderCharts()
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
      // Opcional: Mostrar mensaje de "Sin datos" o limpiar canvas
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
          data: data,
          backgroundColor: colors,
          borderRadius: 8,
          borderWidth: 0,
          barThickness: 30
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: { color: 'rgba(156, 163, 175, 0.1)' },
            ticks: { font: { weight: 'bold' } }
          },
          x: {
            grid: { display: false },
            ticks: { font: { weight: 'bold' } }
          }
        }
      }
    })
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
          data: data,
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
            position: 'right',
            labels: {
              usePointStyle: true,
              padding: 20,
              font: { weight: 'bold', size: 11 }
            }
          }
        },
        cutout: '70%'
      }
    })
  }

  disconnect() {
    if (this.incomeChart) this.incomeChart.destroy()
    if (this.occupancyChart) this.occupancyChart.destroy()
  }
}
