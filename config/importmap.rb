# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "theme_switcher", to: "theme_switcher.js"
pin "copy", to: "copy.js"
pin "paste_image", to: "paste_image.js"
pin "image_modal", to: "image_modal.js"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "log_card_click", to: "log_card_click.js"
pin "trix_custom", to: "trix_custom.js"
pin "highlight.js", to: "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.10.0/es/highlight.min.js",
    integrity: "sha384-elZp05EZ8AgjT52C+3CgO6PvSzU18iuXkxKUTMCy/gpbrZPv8R9heZdSBWH7+Lvx"
pin "highlight_init", to: "highlight_init.js"
