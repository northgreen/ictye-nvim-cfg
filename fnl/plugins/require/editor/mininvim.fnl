{1 "echasnovski/mini.nvim"
  :version false
  :opts {:map {:symbols {:encode "█"}}
    :move {}
    :pick {}
    :align {}
    :files {:options {:use_as_default_explorer false}
      :windows {:preview true}}
    :animate {:scroll {} :cursor {:enable false}}
    :diff {}
    :pairs {}
    :ai {}
    :operators {:evaluate {:prefix "g=" :func nil}
      :exchange {:prefix "gx" :reindent_linewise true}
      :multiply {:prefix "gm" :func nil}
      :replace {:prefix "gr" :reindent_linewise true}
      :sort {:prefix "gs" :func nil}}}
  :config (fn [_ opts]
    (set opts.animate.scroll.timing
      ((. (require :mini.animate) :gen_timing :quadratic)
        {:easing "in-out" :duration 300 :unit "total"}))
    (set opts.animate.scroll.subscroll
      ((. (require :mini.animate) :gen_subscroll :equal)
        {:max_output_steps 120}))
    ((. (require :mini.ai) :setup) opts.ai)
    ((. (require :mini.pick) :setup) opts.pick)
    ((. (require :mini.align) :setup) opts.align)
    ((. (require :mini.files) :setup) opts.files)
    ((. (require :mini.move) :setup) opts.move)
    ((. (require :mini.pairs) :setup) opts.pairs)
    ((. (require :mini.operators) :setup) opts.operators)
    (values))}
