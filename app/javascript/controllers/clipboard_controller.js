import { Controller } from "@hotwired/stimulus"

const COPY_MESSAGE_TIMEOUT_MS = 1500

export default class extends Controller {
  static targets = ["source", "message"]
  static values = { errorMessage: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.value)

      this.messageTarget.classList.remove("hidden")

      setTimeout(() => {
        this.messageTarget.classList.add("hidden")
      }, COPY_MESSAGE_TIMEOUT_MS)

    } catch (error) {
      const message = this.errorMessageValue || "Copy failed"
      alert(message)
    }
  }
}
