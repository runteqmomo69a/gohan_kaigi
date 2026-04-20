import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "buttonLabel", "buttonSpinner"]

  submit() {
    this.buttonTarget.disabled = true
    this.buttonLabelTarget.textContent = this.buttonTarget.dataset.loadingText
    this.buttonSpinnerTarget.classList.remove("hidden")
  }
}
