# Topiary 的 Fennel 配置

## 文件与规则

- `languages.ncl` 固定 Fennel grammar revision，缩进为两个空格
- `queries/fennel/formatting.scm` 适配 Topiary 0.8；容器内使用输入换行，不按行宽自动拆行，保留空行
- 有括号的节点通过 `open` 字段共用间距规则；无括号的绑定、键值、条件、累加器和迭代选项按字段补间距
- 字符串（包括 `string_binding`、`docstring`）、成员访问和注释为 leaf；reader macro 前缀紧贴后续表达式
- 复合节点之间用后一个节点的 `@prepend_input_softline` 保留换行：`@append_input_softline` 捕获前一个复合节点时可能漏掉其末尾叶子后的换行

## 验证

从仓库根目录运行，需已安装 Topiary、Fennel CLI（Lua 5.3+）及 mini.test，并已缓存配置中的 grammar：

```sh
TEST_FILE=tests/integration/topiary.lua make test
```

测试覆盖精确排版、二次格式化幂等性、注释/字符串/宏前缀保护，并对根目录 `test.fnl` 逐个顶层形式格式化、重组和运行断言。测试不修改 `test.fnl`，也不进入默认单元测试集合。

## Grammar 限制

`tree-sitter-fennel` revision `8c0d338cdb95285eb5d59a70b513ddaae374786c` 的 `for_form` 没有引用带方括号的迭代绑定规则，不能解析合法的 `(for [i 1 5] ...)`。查询不能修复 parser 的节点缺失。

`test.fnl` 的两处数值 `for` 在回归中明确断言解析失败并原样保留，其余形式格式化后重组运行。整文件直接交给 Topiary 仍会报错；不要用 `--tolerate-parsing-errors` 绕过，错误树下的 `for` 与 `[` 可能被拼接，生成无效 Fennel。
