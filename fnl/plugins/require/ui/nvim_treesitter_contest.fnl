{1 :nvim-treesitter/nvim-treesitter-context
 :event [:BufReadPre]
 :lazy true
 :opts {:enable true ; Can be enabled/disabled later via commands.
        :multiwindow false ; Enable multiwindow support.
        :max_lines 4 ; Window span; values <= 0 mean no limit.
        :min_window_height 0 ; Minimum editor height; values <= 0 mean no limit.
        :line_numbers true
        :multiline_threshold 20 ; Maximum lines for a single context.
        :trim_scope :outer ; Discard inner/outer context lines when max_lines is exceeded.
        :mode :cursor ; Calculate context from cursor or topline.
        :separator nil
        :zindex 20 ; Z-index of the context window.
        :on_attach nil}} ; (fun(buf: integer): boolean): return false to disable attaching.
