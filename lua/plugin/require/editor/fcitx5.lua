return {
  "pysan3/fcitx5.nvim",
  event = "UIEnter",
  -- enabled = options.env.os.win == 0,
  enabled = false,
  config = function()
    local en = "keyboard-us"
    local ja = "rime"
    require("fcitx5").setup({
      imname = {
        norm = en,
        ins = ja,
        cmd = en,
      },
      remember_prior = true,
    })
  end
}
