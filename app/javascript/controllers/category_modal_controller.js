import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "select", "nameInput", "error"]
  static values = { categoriesUrl: String }

  open() {
    this.modalTarget.classList.remove("is-hidden")
    this.nameInputTarget.value = ""
    this.errorTarget.classList.add("is-hidden")
    this.nameInputTarget.focus()
  }

  close() {
    this.modalTarget.classList.add("is-hidden")
  }

  handleKeydown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.submit()
    } else if (event.key === "Escape") {
      this.close()
    } else if (event.key === "Tab") {
      this.#trapFocus(event)
    }
  }

  async submit() {
    const name = this.nameInputTarget.value.trim()
    if (!name) {
      this.#showError("カテゴリ名を入力してください。")
      return
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(this.categoriesUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ category: { name } })
      })

      const data = await response.json()

      if (response.ok) {
        const option = new Option(data.name, String(data.id), true, true)
        this.selectTarget.appendChild(option)
        this.selectTarget.value = String(data.id)
        this.close()
      } else {
        this.#showError(data.errors?.join("、") || "エラーが発生しました。")
      }
    } catch {
      this.#showError("通信エラーが発生しました。")
    }
  }

  #trapFocus(event) {
    const focusable = this.modalTarget.querySelectorAll(
      'button, input, [tabindex]:not([tabindex="-1"])'
    )
    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    if (event.shiftKey ? document.activeElement === first : document.activeElement === last) {
      event.preventDefault()
      ;(event.shiftKey ? last : first).focus()
    }
  }

  #showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("is-hidden")
  }
}
