if vim.g.lite_mode then
    return
end

if _G.configed[vim.bo.filetype] then
  return
end

_G.configed[vim.bo.filetype] = true

local dap = require("dap")

dap.adapters.php = {
  type = 'executable',
  command = 'php-debug-adapter',
  -- args = { '/path/to/vscode-php-debug/out/phpDebug.js' }
}

dap.configurations.php = {
  {
    type = 'php',
    request = 'launch',
    name = 'Listen for Xdebug',
    port = 9003
  }
}
