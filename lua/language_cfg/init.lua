local Autocmd = vim.api.nvim_create_autocmd
local initd = false
local p = 'language_cfg.languages'
local t = 'language_cfg.toolchain'

vim.opt.completeopt = {'noselect', 'noinsert'}
vim.opt.complete = ''

local init_table = {
    lua = function() require(p .. '.lua.lua_config') end,
    ps1 = function() require(p .. '.pwsh.pwsh') end,
    rust = function() require(p .. '.rust.rust_config') end,
    json = function() require(p .. '.json.json_config') end,
    python = function() require(p .. '.python.python_config') end,
    c = function() require(p .. '.c_cpp.c_cpp_config') end,
    cpp = function() require(p .. '.c_cpp.c_cpp_config') end,
    autohotkey = function() require(p .. '.autohotkey.config') end
}

local function init()
    require'mason-lspconfig'.setup()
    require('dapui').setup()

    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    require'lspconfig'.clangd.setup({capabilities = capabilities})
    require'lspconfig'.cmake.setup({capabilities = capabilities})
    require'lspconfig'.html.setup({capabilities = capabilities})
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

Autocmd('BufReadPre',{callback = function ()
        if not initd then init() end
end})

Autocmd('BufEnter', {
    callback = function(arg)

        local ft = vim.bo[arg.buf].filetype
        local i = init_table[ft]
        if i then
            i()
            init_table[ft] = nil
            attach_lsp_to_existing_buffers()
        end
    end
})

