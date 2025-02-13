local M = {}

local navic = require("nvim-navic")
function M.attach(client, buffer) navic.attach(client, buffer) end

return M
