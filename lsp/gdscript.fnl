;;;@brief
;;;
;;; https://github.com/godotengine/godot
;;;
;;; Language server for GDScript, used by Godot Engine.

(local port (or (os.getenv "GDScript_Port") "6005"))
(local cmd (vim.lsp.rpc.connect "127.0.0.1" (tonumber port)))

;;;@type vim.lsp.Config
{:cmd cmd
  :filetypes ["gd" "gdscript" "gdscript3"]
  :root_markers ["project.godot" ".git"]}
