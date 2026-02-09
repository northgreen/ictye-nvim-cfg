return {
    "nicolasgb/jj.nvim",
    cmd = {
        'J',
        'Jdiff',
        'Jhdiff',
        'Jvdiff'
    },
    config = function()
        require("jj").setup({})
    end,
}
