local function patch_treesitter_range()
    local original_get_node_text = vim.treesitter.get_node_text
    vim.treesitter.get_node_text = function(node, buf, opts)
        local ok, result = pcall(original_get_node_text, node, buf, opts)
        if not ok then
            return ""
        end
        return result
    end
    
    -- Patch nvim-treesitter query predicates if available
    local ok, predicates = pcall(require, 'nvim-treesitter.query_predicates')
    if ok and type(predicates) == "table" and predicates.handler then
        local original_handler = predicates.handler
        predicates.handler = function(...)
            local success, result = pcall(original_handler, ...)
            if not success then
                return false
            end
            return result
        end
    end
    
    print("[Monkepatch] Treesitter range patch applied")

    local v = vim.version()
    if v.major > 0 and v.minor >= 13 then
        vim.schedule(function()
            vim.notify(
                "[WARNING] Neovim 已更新到 " .. v.major .. "." .. v.minor .. 
                ".x，请考虑移除 init.lua 中的 treesitter monkey patch (patch_treesitter_range)",
                vim.log.levels.WARN
            )
        end)
    end
end
vim.defer_fn(patch_treesitter_range, 100)
