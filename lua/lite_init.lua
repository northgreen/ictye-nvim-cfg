local ploadmodule = require 'util.module_load_utils'.ploadmodule

-- load modules
local plugins = ploadmodule 'plugins'
if plugins and plugins.setup then
  plugins.setup()
end

ploadmodule 'core.lite_init'
