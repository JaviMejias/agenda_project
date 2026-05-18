import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scrollable", "leftArrow", "rightArrow"]

  connect() {
    this.container = this.hasScrollableTarget ? this.scrollableTarget : this.element

    this.isDown = false
    this.moved = false
    this.startX = 0
    this.startScrollLeft = 0

    this.mouseDownHandler = this.mouseDown.bind(this)
    this.mouseLeaveHandler = this.mouseLeave.bind(this)
    this.mouseUpHandler = this.mouseUp.bind(this)
    this.mouseMoveHandler = this.mouseMove.bind(this)
    this.clickHandler = this.click.bind(this)
    this.scrollHandler = this.updateArrowVisibility.bind(this)

    this.container.addEventListener("mousedown", this.mouseDownHandler)
    this.container.addEventListener("mouseleave", this.mouseLeaveHandler)
    this.container.addEventListener("mouseup", this.mouseUpHandler)
    this.container.addEventListener("mousemove", this.mouseMoveHandler)
    this.container.addEventListener("click", this.clickHandler, true)
    this.container.addEventListener("scroll", this.scrollHandler)

    if (window.ResizeObserver) {
      this.resizeObserver = new ResizeObserver(() => this.updateArrowVisibility())
      this.resizeObserver.observe(this.container)
    }

    this.container.style.cursor = "grab"
    this.container.style.userSelect = "none"

    setTimeout(() => {
      this.updateArrowVisibility()
    }, 150)
  }

  disconnect() {
    this.container.removeEventListener("mousedown", this.mouseDownHandler)
    this.container.removeEventListener("mouseleave", this.mouseLeaveHandler)
    this.container.removeEventListener("mouseup", this.mouseUpHandler)
    this.container.removeEventListener("mousemove", this.mouseMoveHandler)
    this.container.removeEventListener("click", this.clickHandler, true)
    this.container.removeEventListener("scroll", this.scrollHandler)

    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
    }
  }

  mouseDown(e) {
    this.isDown = true
    this.moved = false
    this.container.style.cursor = "grabbing"
    this.startX = e.pageX - this.container.offsetLeft
    this.startScrollLeft = this.container.scrollLeft
  }

  mouseLeave() {
    this.isDown = false
    this.container.style.cursor = "grab"
  }

  mouseUp() {
    this.isDown = false
    this.container.style.cursor = "grab"

    if (this.moved) {
      setTimeout(() => {
        this.moved = false
      }, 50)
    }
  }

  mouseMove(e) {
    if (!this.isDown) return
    e.preventDefault()

    const x = e.pageX - this.container.offsetLeft
    const walk = (x - this.startX) * 1.5

    if (Math.abs(walk) > 5) {
      this.moved = true
    }

    this.container.scrollLeft = this.startScrollLeft - walk
  }

  click(e) {
    if (this.moved) {
      e.preventDefault()
      e.stopPropagation()
    }
  }

  slideLeft() {
    this.container.scrollBy({ left: -220, behavior: "smooth" })
  }

  slideRight() {
    this.container.scrollBy({ left: 220, behavior: "smooth" })
  }

  updateArrowVisibility() {
    const scrollWidth = this.container.scrollWidth
    const clientWidth = this.container.clientWidth
    const scrollLeft = this.container.scrollLeft

    const hasLeftScroll = scrollLeft > 3
    const hasRightScroll = scrollLeft + clientWidth < scrollWidth - 3

    if (this.hasLeftArrowTarget) {
      if (hasLeftScroll) {
        this.leftArrowTarget.classList.remove("opacity-0", "pointer-events-none")
        this.leftArrowTarget.classList.add("opacity-100")
      } else {
        this.leftArrowTarget.classList.add("opacity-0", "pointer-events-none")
        this.leftArrowTarget.classList.remove("opacity-100")
      }
    }

    if (this.hasRightArrowTarget) {
      if (hasRightScroll) {
        this.rightArrowTarget.classList.remove("opacity-0", "pointer-events-none")
        this.rightArrowTarget.classList.add("opacity-100")
      } else {
        this.rightArrowTarget.classList.add("opacity-0", "pointer-events-none")
        this.rightArrowTarget.classList.remove("opacity-100")
      }
    }
  }
}
