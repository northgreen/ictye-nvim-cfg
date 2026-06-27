local twc = require 'util.functions'.three_way_compare

local ret = {}

ret.os = {
  win = vim.fn.has("win32"),
  linux = vim.fn.has("unix"),
  mac = vim.fn.has("mac"),
}

ret.term = require("global.env_assessment.term")

ret.required = {
  chack = function(self)
    local r = true
    for _, bin in ipairs(self.required) do
      local n = vim.fn.executable(bin)
      if n == 0 then
        vim.notify("Required binary not found: " .. bin, vim.log.levels.ERROR)
        r = false
      end
    end
    return r
  end,
  required = {
    -- here the required command-line tool
    'git',
    'fd',
    'npm',
    'gcc',
    'gh',
    'rg',
    'node',
    'fennel',
    twc(ret.os.linux + ret.os.mac > 0, 'make', 'pwsh')
  },
  optional = {
    'cmake',
    'pass',
    'jjui',
    'jj',
    'lazygit',
    'opencode',
  }
}

return ret
