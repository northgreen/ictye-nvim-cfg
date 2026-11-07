; Topiary 0.8 / tree-sitter-fennel 8c0d338：两空格缩进，保留输入中的换行和空行
; 只在表达式边界插入间距，避免拆开 foo.bar、obj:method 和 reader macro

; 字符串的内容（包括多行字符串）不能随代码重新缩进
[
  (string)
  (string_binding)
  (docstring)
  (multi_symbol)
  (multi_symbol_method)
  (comment)
  (shebang)
] @leaf

(_) @allow_blank_line_before

; 顶层表达式各占一行，但行尾注释仍留在所属表达式之后
(program
  (_) @append_hardline
  .
  (comment)* @do_nothing)

(comment) @prepend_input_softline @append_hardline
(shebang) @append_hardline

; 所有括号容器共用平衡的缩进，覆盖 list、特殊形式、解构和参数/迭代绑定
["(" "[" "{"] @append_antispace @append_empty_input_softline @append_indent_start
[")" "]" "}"] @prepend_antispace @prepend_indent_end

; 有 open 字段的容器内，相邻命名节点之间至少一个空格；已有换行保留
; 将 open 限定为括号，避免匹配字符串的冒号/引号以及符号内部片段
; 从后一个节点 prepend：append 到复合节点会漏掉其末尾叶子之后的输入换行
(_
  open: ["(" "[" "{"]
  (_)
  .
  (_) @prepend_input_softline)

; quote / quasiquote / unquote / hashfn 前缀必须紧贴表达式
(_ macro: _ @append_antispace)

; 没有括号的 pair 节点也需要间距，不能只处理普通 list
; let/local/var/global 绑定、模式分支、rest 解构
(_
  lhs: (_)
  rhs: (_) @prepend_input_softline)

; 普通表、表解构与函数 metadata 中的键值对
(_
  key: (_)
  value: (_) @prepend_input_softline)

; if 的条件与结果、accumulate 的累加器和迭代选项
(if_pair
  condition: (_)
  expression: (_) @prepend_input_softline)

(accumulator_pair
  accumulator_binding: (_)
  accumulator_value: (_) @prepend_input_softline)

(iter_option
  option: (_)
  value: (_) @prepend_input_softline)

; set 的 lhs/rhs 在当前 grammar 中属于内联节点，仍由上面的字段匹配处理
; for_iter_body 的数值序列由容器规则处理（fcollect / faccumulate）
; TODO: 上游 for_form 未引用带 [] 的规则，合法数值 for 暂时无法被 Topiary 解析
