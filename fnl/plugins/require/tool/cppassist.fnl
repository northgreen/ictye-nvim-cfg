{1 "Kohirus/cppassist.nvim"
  :ft ["h" "cpp" "hpp" "c" "cc" "cxx"]
  :opts {;; For SwitchSourceAndHeader, ImplementInSource and ImplementOutOfClass.
    :switch_sh {;; Directories searched for target files.
      :include_dirs ["." ".."]
      ;; Directories excluded from the search.
      :exclude_dirs []
      ;; See man fd: -t accepts multiple types, -s is case-sensitive,
      ;; and -L follows symbolic links.
      :search_flags "-tf -s -L"
      ;; Return values selected by keywords in the return type.
      :return_type {:int "0" :short "0" :long "0" :char "0"
        :double "0.0" :float "0.0" :bool "false"
        :pointer "nullptr"}}
    ;; For GotoHeaderFile.
    :goto_header {:include_dirs ["." ".." "/usr/include" "/usr/local/include" "~"]
      :exclude_dirs []
      :search_flags "-tf -s"}}
  :keys (. (require :core.keymap) :cppassist)}
