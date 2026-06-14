import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "prevBtn", "nextBtn", "counter", "thumb"]

  #images = []
  #currentIndex = 0

  connect() {
    this.#images = this.thumbTargets.map(t => t.dataset.fullUrl)
  }

  open({ params: { index } }) {
    this.#currentIndex = index
    this.#show()
  }

  close() {
    this.modalTarget.setAttribute("hidden", "hidden")
    this.imageTarget.src = ""
    this.imageTarget.alt = ""
    document.body.classList.remove("is-modal-open")
  }

  prev() {
    this.#currentIndex = (this.#currentIndex - 1 + this.#images.length) % this.#images.length
    this.#show()
  }

  next() {
    this.#currentIndex = (this.#currentIndex + 1) % this.#images.length
    this.#show()
  }

  navigateWithKeyboard(event) {
    if (this.modalTarget.hasAttribute("hidden")) return
    const handlers = { Escape: "close", ArrowLeft: "prev", ArrowRight: "next" }
    const method = handlers[event.key]
    if (method) {
      event.preventDefault()
      this[method]()
    }
  }

  #show() {
    const total = this.#images.length
    this.imageTarget.src = this.#images[this.#currentIndex]
    this.imageTarget.alt = `画像 ${this.#currentIndex + 1} / ${total}`
    this.modalTarget.removeAttribute("hidden")
    document.body.classList.add("is-modal-open")
    this.#updateNav()
    this.modalTarget.querySelector(".image-modal-close")?.focus()
  }

  #updateNav() {
    const total = this.#images.length
    const single = total <= 1

    this.prevBtnTarget.hidden = single
    this.nextBtnTarget.hidden = single
    this.counterTarget.hidden = single
    if (!single) {
      this.counterTarget.textContent = `${this.#currentIndex + 1} / ${total}`
    }
  }
}
