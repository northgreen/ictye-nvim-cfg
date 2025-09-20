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
    require'mason-lspconfig'.setup()
    require('dapui').setup()

    require(t .. '.toolchain_init')
end

local attach_lsp_to_existing_buffers = vim.schedule_wrap(function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local valid = vim.api.nvim_buf_is_valid(bufnr) and
                          vim.bo[bufnr].buflisted
        if valid and vim.bo[bufnr].buftype == "" then
            local clients = vim.lsp.get_clients({bufnr = bufnr})
            if #clients == 0 then
                vim.api.nvim_exec_autocmds("FileType", {buffer = bufnr})
            end
        end
    end
end)

--- lsp configed
_G.configed = {}
--- lsp attached
_G.attached = {}

Autocmd('BufRead', {
    callback = function(arg)
        if not initd then init() end
        local ft = vim.bo[arg.buf].filetype
        local i = init_table[ft]
        if i then
            i()
            init_table[ft] = nil
        end

        if not _G.attached[ft] then
            attach_lsp_to_existing_buffers()
            _G.attached[ft] = true
        end
    end
})

