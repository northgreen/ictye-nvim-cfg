local config_paths = {
    nvim = vim.fn.stdpath('config') .. "/init.lua",
}


vim.api.nvim_create_user_command('ConfigEdit', function(opts)
    local config_type = opts.args:lower()



    if not config_paths[config_type] then
        vim.notify("Only below config types are supported: \n" ..
            table.concat(vim.tbl_keys(config_paths), ", "), vim.log.levels.ERROR)
        return
    end

    local file_path = config_paths[config_type]

    if vim.fn.filereadable(file_path) == 0 then
        vim.notify("You have no config file for it" .. file_path, vim.log.levels.ERROR)
        return
    end

    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
end, {
    nargs = 1,
    complete = function()
        return vim.tbl_keys(config_paths)
    end,
    desc = "Quick Edit Configs"
})


