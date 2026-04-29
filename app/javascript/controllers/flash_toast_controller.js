import { Controller } from "@hotwired/stimulus"

const TOAST_TIMEOUT_MS = 1800

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.element.remove()
    }, TOAST_TIMEOUT_MS)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
