local function show_lsp_actions_menu()
  local nui_menu = require("nui.menu")
  local event = require("nui.utils.autocmd").event

  local lsp_actions = {
    { "1. 跳转到定义", vim.lsp.buf.definition },
    { "2. 跳转到声明", vim.lsp.buf.declaration },
    { "3. 跳转到类型定义", vim.lsp.buf.type_definition },
    { "4. 跳转到实现", vim.lsp.buf.implementation },
    { "5. 查找引用", vim.lsp.buf.references },
    { "6. 悬停文档", vim.lsp.buf.hover },
    { "7. 签名帮助", vim.lsp.buf.signature_help },
    { "8. 重命名符号", vim.lsp.buf.rename },
    { "9. 代码操作", vim.lsp.buf.code_action },
    { "10. 格式化文件", function() vim.lsp.buf.format({ async = true }) end },
    { "11. 显示诊断信息", vim.diagnostic.open_float },
    { "12. 工作区符号搜索", vim.lsp.buf.workspace_symbol },
  }

  local menu_items = {}
  for i, action in ipairs(lsp_actions) do
    table.insert(menu_items, nui_menu.item(action[1], { action = action[2] }))
  end

  local menu = nui_menu({
    position = "50%",
    size = {
      width = 40,
      height = #lsp_actions,
    },
    border = {
      style = "rounded",
      text = {
        top = "Lsp Actions",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  }, {
    lines = menu_items,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>", "q" },
      submit = { "<CR>", "<Space>" },
    },
    on_submit = function(item)
      if item.action then
        item.action()
      end
    end,
  })

  menu:mount()
end

return show_lsp_actions_menu
