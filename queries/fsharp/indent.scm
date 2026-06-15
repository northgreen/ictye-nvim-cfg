; indent.scm for F# (Neovim treesitter)

; 成对结构：增加子节点缩进
[
  (let_binding)
  (let_expr)
  (match_expr)
  (if_expr)
  (while_expr)
  (for_expr)
  (try_expr)
  (object_expr)
  (class_declaration)
  (type_declaration)
  (module_declaration)
] @indent.begin

; 关闭缩进的标记（结束符）
[
  "end"
  "done"
  ")"
  "]"
  "}"
] @indent.end

; 匹配分支中的 '|' 对齐（不额外缩进）
(pat_match_branch) @indent.align

; 特定关键字后缩进
[
  "="
  "->"
  "then"
  "else"
  "in"
  "with"
  "struct"
  "sig"
  "begin"
  "do"
  "fun"
  "function"
  "private"
  "inherit"
  "initializer"
] @indent

; 顶级 ';;' 重置缩进
"###" @indent.zero  ; 或者使用专用节点，若解析器提供

; 多行注释中的 '*' 对齐（可选）
(comment) @indent.auto

; 延续行（参数/列表元素）保持相对缩进
(argument) @indent.cont
(list_element) @indent.cont
