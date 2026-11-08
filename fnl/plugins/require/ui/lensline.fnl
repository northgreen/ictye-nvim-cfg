{1 :oribarilan/lensline.nvim
 :tag "2.0.0" ; Or :branch "release/2.x" for latest non-breaking updates.
 :event :LspAttach
 :config (fn []
           ((. (require :lensline) :setup))
           (values))}
