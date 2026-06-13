import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "arrow", "tagInput", "toggleButton"]

  toggle() {
    const hidden = this.listTarget.classList.toggle("is-hidden")
    this.arrowTarget.textContent = hidden ? "▼" : "▲"
    this.toggleButtonTarget.setAttribute("aria-expanded", String(!hidden))
  }

  addTag({ params: { name } }) {
    if (!this.hasTagInputTarget) return
    const input = this.tagInputTarget

    const tags = input.value
      ? input.value.split(",").map(t => t.trim()).filter(Boolean)
      : []

    if (!tags.some(t => t.toLowerCase() === name.toLowerCase())) {
      tags.push(name)
      input.value = tags.join(", ")
    }

    input.focus()
  }
}
