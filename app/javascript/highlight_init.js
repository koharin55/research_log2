import hljs from "highlight.js";

const applyHighlight = () => {
  document.querySelectorAll("pre code:not(.hljs)").forEach((el) => {
    hljs.highlightElement(el);
  });
};

const syncHljsTheme = () => {
  const theme = document.documentElement.getAttribute("data-theme");
  const lightCss = document.getElementById("hljs-light-css");
  const darkCss = document.getElementById("hljs-dark-css");
  if (!lightCss || !darkCss) return;
  lightCss.disabled = theme === "dark";
  darkCss.disabled = theme !== "dark";
};

// data-theme 属性の変化を監視してテーマCSSを切り替える
const observer = new MutationObserver(syncHljsTheme);
observer.observe(document.documentElement, {
  attributes: true,
  attributeFilter: ["data-theme"],
});

// turbo:load がメイン。Importmap のモジュール評価が初回 turbo:load より遅れる場合の
// フォールバックとして DOMContentLoaded も登録する。
// applyHighlight 内の :not(.hljs) チェックにより二重処理は防いでいる。
document.addEventListener("turbo:load", () => {
  applyHighlight();
  syncHljsTheme();
});

document.addEventListener("DOMContentLoaded", () => {
  applyHighlight();
  syncHljsTheme();
});
