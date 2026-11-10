;;;@brief
;;;
;;; https://github.com/olrtg/emmet-language-server
;;;
;;; Package can be installed via `npm`:
;;; ```sh
;;; npm install -g @olrtg/emmet-language-server
;;; ```

;;;@type vim.lsp.Config
{:cmd ["emmet-language-server" "--stdio"]
  :filetypes ["astro" "css" "eruby" "html" "htmlangular" "htmldjango" "javascriptreact"
    "less" "sass" "scss" "svelte" "typescriptreact" "vue" "php"]
  :root_markers [".git"]}
