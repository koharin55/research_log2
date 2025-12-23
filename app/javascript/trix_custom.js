import "trix"

// カスタム属性の定義
Trix.config.textAttributes.underline = {
  tagName: "u",
  inheritable: true,
}

Trix.config.textAttributes.redText = {
  style: { color: "#d32f2f" },
  inheritable: true,
  parser: el => el.style.color === "rgb(211, 47, 47)",
}

Trix.config.textAttributes.blueText = {
  style: { color: "#4472c4" }, // よりはっきりした青
  inheritable: true,
  parser: el => el.style.color === "rgb(30, 75, 184)",
}

document.addEventListener("trix-initialize", event => {
  const toolbar = event.target.toolbarElement
  if (!toolbar) return

  // 既存のテキスト系グループを探す（なければブロック系に差し込む）
  const textGroup =
    toolbar.querySelector(".trix-button-group--text-tools") ||
    toolbar.querySelector(".trix-button-group")
  if (!textGroup) return

  const makeBtn = ({ attr, title, text, className }) => {
    const btn = document.createElement("button")
    btn.type = "button"
    btn.className = `trix-button trix-button--icon ${className}`
    btn.setAttribute("data-trix-attribute", attr)
    btn.setAttribute("title", title)
    btn.setAttribute("tabindex", "-1")
    btn.textContent = text
    return btn
  }

  textGroup.append(
    makeBtn({
      attr: "underline",
      title: "下線",
      text: "U",
      className: "trix-button--icon-underline-custom",
    }),
    makeBtn({
      attr: "redText",
      title: "赤字",
      text: "A",
      className: "trix-button--icon-red-custom",
    }),
    makeBtn({
      attr: "blueText",
      title: "青字",
      text: "A",
      className: "trix-button--icon-blue-custom",
    }),
  )
})
