--- @author Ictye
--- Configuration file for Neovim
local ploadmodule = require 'util.module_load_utils'.ploadmodule

-- load modules
ploadmodule 'plugin_init'
ploadmodule 'plugin_config'

-- configs
ploadmodule 'config_init'

-- some test code
ploadmodule 'test.test_init'

