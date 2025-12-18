return {
    "pysan3/fcitx5.nvim",
    -- enabled = false,
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
