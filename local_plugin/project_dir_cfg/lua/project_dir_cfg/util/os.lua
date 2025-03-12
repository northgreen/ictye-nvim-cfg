local M = {}
M.is_windows = vim.fn.has('win32') == 1
return M
