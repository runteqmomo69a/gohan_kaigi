import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["url", "name", "message", "button"]
  static values = { endpoint: String }

  async fetch(event) {
    event.preventDefault()

    const url = this.urlTarget.value.trim()

    if (!url) {
      this.showMessage("URLを入力してください", false)
      return
    }

    this.buttonTarget.disabled = true

    try {
      const response = await window.fetch(this.endpointValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ url })
      })

      const data = await response.json()

      if (response.ok && data.name) {
        this.nameTarget.value = data.name
        this.showMessage("店名候補を反映しました", true)
      } else {
        this.showMessage(data.error || "店名候補を取得できませんでした", false)
      }
    } catch (_error) {
      this.showMessage("店名取得中にエラーが発生しました", false)
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  showMessage(message, success) {
    this.messageTarget.textContent = message
    this.messageTarget.classList.remove("hidden", "text-base-content/50", "text-[#c45f3d]", "text-[#5f7d4e]")
    this.messageTarget.classList.add(success ? "text-[#5f7d4e]" : "text-[#c45f3d]")
  }
}
