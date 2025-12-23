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
  style: { color: "#4472c4" }, 
  inheritable: true,
  parser: el => el.style.color === "rgb(68, 114, 196)",
}

// 任意の文字サイズ
Trix.config.textAttributes.fontSize = {
  styleProperty: "fontSize",
  inheritable: true,
  parser: el => el.style.fontSize || null,
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

  // 文字サイズセレクト
  const sizeWrapper = document.createElement("span")
  sizeWrapper.className = "trix-button-group trix-button-group--font-size"

  const sizeSelect = document.createElement("select")
  sizeSelect.className = "trix-font-size-select"
  sizeSelect.setAttribute("title", "文字サイズ")
  sizeSelect.innerHTML = `
    <option value="">サイズ</option>
    <option value="12px">12px</option>
    <option value="14px">14px</option>
    <option value="16px">16px</option>
    <option value="18px">18px</option>
    <option value="20px">20px</option>
    <option value="24px">24px</option>
  `

  sizeSelect.addEventListener("change", () => {
    const editor = event.target.editor
    if (!editor) return
    const value = sizeSelect.value
    if (value) {
      editor.activateAttribute("fontSize", value)
    } else {
      editor.deactivateAttribute("fontSize")
    }
    event.target.focus()
  })

  sizeWrapper.appendChild(sizeSelect)

  // テキストツールグループの直後に配置
  textGroup.after(sizeWrapper)
})

// リンク入力欄をリンクボタン付近に表示
document.addEventListener("trix-show-dialog", event => {
  if (event.detail?.dialogName !== "link") return
  const editor = event.target
  const toolbar = editor?.toolbarElement
  if (!toolbar) return

  const linkButton =
    toolbar.querySelector("[data-trix-attribute='href']") ||
    toolbar.querySelector("[data-trix-action='link']")
  const dialogs = toolbar.querySelector(".trix-dialogs")
  if (!linkButton || !dialogs) return

  const toolbarRect = toolbar.getBoundingClientRect()
  const buttonRect = linkButton.getBoundingClientRect()
  const left = Math.max(0, buttonRect.left - toolbarRect.left)
  const top = Math.max(0, buttonRect.bottom - toolbarRect.top + 6)

  dialogs.style.left = `${left}px`
  dialogs.style.top = `${top}px`
  dialogs.style.right = "auto"
  dialogs.style.bottom = "auto"
})

document.addEventListener("trix-hide-dialog", event => {
  if (event.detail?.dialogName !== "link") return
  const editor = event.target
  const toolbar = editor?.toolbarElement
  if (!toolbar) return
  const dialogs = toolbar.querySelector(".trix-dialogs")
  if (!dialogs) return
  dialogs.style.left = ""
  dialogs.style.top = ""
  dialogs.style.right = ""
  dialogs.style.bottom = ""
})
