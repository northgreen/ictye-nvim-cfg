{1 "magicmonty/sonicpi.nvim"
  :opts {:server_dir (if (= options.env.os.win 1)
      "C:\\Program Files\\Sonic Pi\\app\\server"
      "/opt/sonic-pi/app/server ")}
  :event "VeryLazy"
  :requires ["hrsh7th/nvim-cmp" "kyazdani42/nvim-web-devicons"]}
