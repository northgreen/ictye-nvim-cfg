--- @author Ictye
--- Configuration file for Neovim
--- CopyUp(x) by Ictye(northgreen)

local function script_path()
    local str = debug.getinfo(1, 'S').source:sub(2)
    return str:match('(.*[/ \\])')
end
local path = script_path() .. '?.lua'
package.path =
    package.path .. ';' .. path .. ';..\\?.lua' .. ';..\\?\\init.lua' .. ';'

local ploadmodule = require 'util.module_load_utils'.ploadmodule
require 'env_init'

ploadmodule 'options'

-- load modules
ploadmodule 'plugin_init'
ploadmodule 'plugin_config'

-- configs
ploadmodule 'config_init'
ploadmodule 'core.autocommand_set'
ploadmodule 'core.highlights'

-- some test code
ploadmodule 'test.test_init'

