local Autocmd = vim.api.nvim_create_autocmd
local initd = false
local p = 'configs.language_cfg.languages'
local t = 'configs.language_cfg.toolchain'

vim.opt.completeopt = {'noselect', 'noinsert'}
vim.opt.complete = ''

local init_table = {
    c = function() require(p .. '.c_cpp.c_cpp_config') end,
    cpp = function() require(p .. '.c_cpp.c_cpp_config') end,
    fs = function() require(p .. "fsharp.fsharp_config") end,
}

local function init()
    -- require'mason-lspconfig'.setup()
    require('dapui').setup()

    require(t .. '.toolchain_init')
end

_G.configed={}

Autocmd('BufRead', {
    callback = function(arg)
        if not initd then init() end
        local ft = vim.bo[arg.buf].filetype
        local i = init_table[ft]
        if i then
            i()
            init_table[ft] = nil
        end
    end
})

