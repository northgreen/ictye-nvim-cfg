local twc = require('util.functions').three_way_compare
--- @return LazyPluginSpec
return {
  'magicmonty/sonicpi.nvim',
  opts = {
    server_dir = twc(options.env.os.win == 1,
      "C:\\Program Files\\Sonic Pi\\app\\server", "/opt/sonic-pi/app/server "),
  },
  -- lazy = false,
  event = "VeryLazy",
  requires = {
    'hrsh7th/nvim-cmp',
    'kyazdani42/nvim-web-devicons',
  }
}
