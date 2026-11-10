{1 "jake-stewart/multicursor.nvim"
  :branch "1.0"
  :config (fn []
    (local mc (require :multicursor-nvim))
    (mc.setup)
    (mc.addKeymapLayer
      (fn [layerSet]
        ;; Select a different cursor as the main one.
        (layerSet ["n" "x"] "<left>" mc.prevCursor)
        (layerSet ["n" "x"] "<right>" mc.nextCursor)
        ;; Delete the main cursor.
        (layerSet ["n" "x"] "<leader>x" mc.deleteCursor)
        ;; Enable and clear cursors using escape.
        (layerSet "n" "<esc>"
          (fn []
            (if (not (mc.cursorsEnabled))
              (mc.enableCursors)
              (mc.clearCursors))
            nil))
        nil))
    nil)
  :keys (. (require :core.keymap) :muti_cursor)}
