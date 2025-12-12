return function (caps)
    if not caps then
        caps = {}
    end
    vim.tbl_extend("keep",caps,{
        dynamicRegistration = false,
        lineFoldingOnly = true
    })
    return require('blink-cmp').get_lsp_capabilities(caps)
end
