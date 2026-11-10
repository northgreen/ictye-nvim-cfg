;; Returns LazyPluginSpec.
{1 "iamcco/markdown-preview.nvim"
  :enabled false
  :cmd ["MarkdownPreviewToggle" "MarkdownPreview" "MarkdownPreviewStop"]
  :ft ["markdown"]
  :build (fn []
    ((. vim.fn :mkdp#util#install))
    nil)}
