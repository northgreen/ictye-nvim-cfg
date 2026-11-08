{1 :nicolasgb/jj.nvim
 :cmd [:J :Jdiff :Jhdiff :Jvdiff]
 :config (fn []
           ((. (require :jj) :setup) {})
           (values))}
