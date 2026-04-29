import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.element.remove()
    }, 1800)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
