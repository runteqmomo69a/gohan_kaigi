import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  search() {
    const query = this.inputTarget.value

    if (query.length === 0) {
      this.resultsTarget.innerHTML = ""
      this.resultsTarget.classList.add("hidden")
      return
    }

    fetch(`/shop_logs/autocomplete?q=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        this.resultsTarget.innerHTML = ""

        data.forEach((name) => {
          const item = document.createElement("div")
          item.textContent = name
          item.className = "p-2 hover:bg-gray-100 cursor-pointer"

          item.addEventListener("click", () => {
            this.inputTarget.value = name
            this.resultsTarget.innerHTML = ""
            this.resultsTarget.classList.add("hidden")
          })

          this.resultsTarget.appendChild(item)
        })

        if (data.length > 0) {
          this.resultsTarget.classList.remove("hidden")
        } else {
          this.resultsTarget.classList.add("hidden")
        }
      })
  }
}
