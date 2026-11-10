{1 :NickvanDyke/opencode.nvim
  :enabled false
  :keys (. (require :core.keymap) :opencode)
  :dependencies [;; @module 'snacks'
    {1 :folke/snacks.nvim :opts {:input {} :picker {} :terminal {}}}]
  :config (fn []
    ;; @type opencode.Opts
    (set vim.g.opencode_opts
      {:server {:start (fn []
            (if (= vim.env.TERM :xterm-kitty)
              (vim.fn.system [:kitty "@" :launch
                  "--location=vsplit"
                  "--keep-focus"
                  "--cwd" (vim.fn.getcwd)
                  :opencode "--port"])
              (let [opencode_cmd "opencode --port"
                  ;; @type snacks.terminal.Opts
                  snacks_terminal_opts {:win {:position :right
                      :enter false}}]
                ((. (require :snacks.terminal) :open)
                  opencode_cmd snacks_terminal_opts)))
            (values))}})
    ;; Required for `opts.events.reload`.
    (set vim.o.autoread true)
    (values))}
