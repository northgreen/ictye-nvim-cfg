local ploadmodule = require 'util.module_load_utils'.ploadmodule

vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- load modules
ploadmodule "config"

-- configs
ploadmodule 'configs'

-- some test code
ploadmodule 'test'
