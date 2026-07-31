{
  1 "dmtrKovalenko/fff.nvim"
  :build (fn []
    ; downloads a prebuilt binary or falls back to cargo build
    ((. (require :fff.download) :download_or_build_binary)))
  :opts {:debug {:enabled true :show_scores true}}
  :lazy false ; the plugin lazy-initialises itself
  :keys [
    {1 "ff" 2 (fn [] ((. (require :fff) :find_files))) :desc "FFFind files"}
    {1 "fg" 2 (fn [] ((. (require :fff) :live_grep))) :desc "LiFFFe grep"}
    {1 "fz" 2 (fn [] ((. (require :fff) :live_grep) {:grep {:modes ["fuzzy" "plain"]}})) :desc "Live fffuzy grep"}
    {1 "fw" 2 (fn [] ((. (require :fff) :live_grep_under_cursor))) :mode ["n" "x"] :desc "Search current word / selection"}
  ]
}
