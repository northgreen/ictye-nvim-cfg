{1 :zgs225/pi2.nvim
  ;; render-markdown.nvim powers the default chat-history renderer
  ;; (render.engine = "render-markdown"); img-clip.nvim is optional and
  ;; required only for `:PiPasteImage` (clipboard image paste).
  :enabled (= options.llm_config.use_plugin :pi2)
  :dependencies [:MeanderingProgrammer/render-markdown.nvim
    :HakonHarnes/img-clip.nvim]
  ;; if you're fine with defaults:
  :config true}
