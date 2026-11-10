-- 真实 Topiary 回归：TEST_FILE=tests/integration/topiary.lua make test
-- 需要已安装 Topiary 且 Fennel grammar 已缓存；测试不安装依赖。
local MiniTest = require("mini.test")
local T = MiniTest.new_set()
local root = vim.fn.getcwd()
local topiary = vim.env.TOPIARY or "topiary"
local fennel = require("fennel")

local function format(source)
  if vim.fn.executable(topiary) ~= 1 then
    MiniTest.skip("未安装 Topiary")
  end
  return vim
    .system({
      topiary,
      "format",
      "--language",
      "fennel",
      "--configuration",
      root .. "/topiary/languages.ncl",
      "--query",
      root .. "/topiary/queries/fennel/formatting.scm",
    }, { stdin = source, text = true })
    :wait(10000)
end

local function check(source, expected)
  local result = format(source)
  MiniTest.expect.equality(result.code, 0, result.stderr)
  if expected then
    MiniTest.expect.equality(result.stdout, expected)
  end
  local repeated = format(result.stdout)
  MiniTest.expect.equality(repeated.code, 0, repeated.stderr)
  MiniTest.expect.equality(repeated.stdout, result.stdout)
  return result.stdout
end

local examples = {
  { "普通调用和嵌套参数", "( print   (+ 1   2) [ 3  4 ] { :a  5 } )", "(print (+ 1 2) [3 4] {:a 5})\n" },
  { "数值布尔和 nil 参数", '(f 1   true false   nil "x")', '(f 1 true false nil "x")\n' },
  {
    "多行 let 和解构绑定",
    "(let [x  1\ny  (+ x 2)\n[a b] [3 4]]\n(print x y a b))",
    "(let [x 1\n    y (+ x 2)\n    [a b] [3 4]]\n  (print x y a b))\n",
  },
  {
    "函数与参数解构",
    '(fn add [a   {: key}]\n"文档字符串"\n(+ a key))',
    '(fn add [a {: key}]\n  "文档字符串"\n  (+ a key))\n',
  },
  { "表的键值和条目换行", "{:a  1\n:b (+ 2 3)\n:c [4  5]}", "{:a 1\n  :b (+ 2 3)\n  :c [4 5]}\n" },
  {
    "if 与模式匹配",
    "(if (> x 0)   :yes\n:no)\n(match x\n[a b]   (+ a b)\n_ nil)",
    "(if (> x 0) :yes\n  :no)\n(match x\n  [a b] (+ a b)\n  _ nil)\n",
  },
  {
    "迭代器和累加器",
    "(accumulate [acc  0 i v (ipairs xs) &until (> i 3)]\n(+ acc v))",
    "(accumulate [acc 0 i v (ipairs xs) &until (> i 3)]\n  (+ acc v))\n",
  },
  {
    "reader macro 和成员访问",
    "(f '( a   b ) `(+ ,x 1) #(+ $1 1) foo.bar obj:method)",
    "(f '(a b) `(+ ,x 1) #(+ $1 1) foo.bar obj:method)\n",
  },
  {
    "嵌套字符串保持原文",
    '(f "第一行\n  第二行\n" "a\\n\\"b" :x)',
    '(f "第一行\n  第二行\n" "a\\n\\"b" :x)\n',
  },
  {
    "行尾注释和空行",
    "; 标题\n\n(local x 1) ; 行尾\n\n(print x)",
    "; 标题\n\n(local x 1) ; 行尾\n\n(print x)\n",
  },
  {
    "结束括号前的注释",
    "(fn []\n; 注释\n42 ; 返回值\n)",
    "(fn []\n  ; 注释\n  42 ; 返回值\n)\n",
  },
  {
    "shebang 和空容器",
    "#!/usr/bin/env fennel\n(local xs [ ])\n(local t { })\n(values)",
    "#!/usr/bin/env fennel\n(local xs [])\n(local t {})\n(values)\n",
  },
}

for _, example in ipairs(examples) do
  T[example[1]] = function()
    check(example[2], example[3])
  end
end

T["完整语法样例逐形式格式化，其余代码与两处原始 for 重组后可运行"] = function()
  local source = table.concat(vim.fn.readfile("test.fnl"), "\n") .. "\n"
  local parse = fennel.parser(fennel["string-stream"](source), "test.fnl")
  local pieces, cursor, unsupported, formatted = {}, 1, 0, 0
  while true do
    local ok, ast = parse()
    if not ok then
      break
    end
    local location = ast.bytestart and ast or getmetatable(ast)
    local text = source:sub(location.bytestart, location.byteend)
    pieces[#pieces + 1] = source:sub(cursor, location.bytestart - 1)
    if fennel["list?"](ast) and tostring(ast[1]) == "for" then
      -- 不用 tolerate-parsing-errors 掩盖 grammar 缺陷；仅保留已知不支持的形式。
      local result = format(text)
      MiniTest.expect.equality(result.code, 5)
      pieces[#pieces + 1] = text
      unsupported = unsupported + 1
    else
      pieces[#pieces + 1] = check(text):gsub("\n$", "")
      formatted = formatted + 1
    end
    cursor = location.byteend + 1
  end
  pieces[#pieces + 1] = source:sub(cursor)
  MiniTest.expect.equality(unsupported, 2)
  assert(formatted > 100, "应覆盖完整样例中的所有其他顶层形式")
  local output = table.concat(pieces)
  fennel["compile-string"](output, { filename = "formatted-test.fnl" })
  -- 样例中的 // 和原生位运算需要 Lua 5.3+，不能在 Neovim LuaJIT 中运行。
  local command = vim.env.FENNEL or "fennel"
  assert(vim.fn.executable(command) == 1, "运行完整样例需要 Fennel CLI（Lua 5.3+）")
  local result = vim.system({ command, "--eval", output }, { text = true }):wait(10000)
  MiniTest.expect.equality(result.code, 0, result.stderr)
  assert(result.stdout:find("all assertions passed", 1, true), result.stdout)
end

return T
