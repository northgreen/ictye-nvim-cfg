(local twc (. (require :util.functions) :three_way_compare))

{1 "magicmonty/sonicpi.nvim"
  :opts {:server_dir (twc (= _G.options.env.os.win 1)
      "C:\\Program Files\\Sonic Pi\\app\\server"
      "/opt/sonic-pi/app/server ")}
  :event "VeryLazy"
  :requires ["hrsh7th/nvim-cmp" "kyazdani42/nvim-web-devicons"]}
