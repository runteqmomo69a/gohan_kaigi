import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "message"]
  static values = { errorMessage: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.value)

      this.messageTarget.classList.remove("hidden")

      setTimeout(() => {
        this.messageTarget.classList.add("hidden")
      }, 1500)

    } catch (error) {
      const message = this.errorMessageValue || "Copy failed"
      alert(message)
    }
  }
}
