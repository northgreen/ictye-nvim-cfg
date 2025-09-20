if vim.g.lite_mode then
    return
end

local function ts(bufnr)
    local ft = vim.bo[bufnr].filetype
    local lang = vim.treesitter.language.get_lang(ft)

    if not lang then
        return
    end

    if vim.treesitter.get_parser(bufnr, lang) then
        return
    end

    vim.treesitter.start(bufnr, lang)
end

local function on_init(client)
    require('sonicpi').lsp_on_init(client, {
        server_dir = 'C:\\Program Files\\Sonic Pi\\app\\server' -- 路径根据系统调整
    })
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

vim.api.nvim_create_user_command('LspAttachManual', attach_lsp_to_existing_buffers, {})

if _G.configed[vim.bo.filetype] then return end
_G.configed[vim.bo.filetype] = true

local attach = require 'global.language.attach'.attach

vim.lsp.config('solargraph',{
    on_init = on_init,
    filetypes = { "ruby", "sonicpi" },
    settings = {
        single_file = true,
        solargraph = {
            single_file = true,
            dagnostics = true,
        }
    },
    on_attach = function(client, buffer)
        attach(client, buffer)
        vim.defer_fn(function() ts(buffer) end, 20)
    end

})
