local uv = vim.loop -- 使用 Neovim 的内置库

local function find_cargo_and_tags_in_parents(n_path)
    local root_path = n_path:match('^([a-zA-Z]:[/\\])') -- 获取 Windows 根目录，例如 C:\
    while n_path ~= root_path do
        local cargo_path = n_path .. '\\Cargo.toml'
        local tags_path = n_path .. '\\rusty-tags.vi'
        local cargo_file_stat = uv.fs_stat(cargo_path) -- 获取文件信息
        local tags_file_stat = uv.fs_stat(tags_path) -- 获取文件信息
        if cargo_file_stat and cargo_file_stat.type == 'file' and tags_file_stat and tags_file_stat.type == 'file' then
            -- 将 rusty-tags.vi 添加到 Neovim 的 tags 设置中
            vim.api.nvim_command('set tags+=' .. tags_path)
            return cargo_path, tags_path
        end
        n_path = n_path:match('(.*)[/\\]') -- 更新路径，向上移动一级
    end
    return nil, nil
end

-- 执行 ctags 命令
local function run_ctags(n_path)
    local ctags_command = 'ctags -R ' .. n_path
    handle, pid = uv.spawn('cmd', {
        args = {'/c', ctags_command},
        stdio = {nil, nil, nil}
    }, function(code)
        handle:close()
        if code ~= 0 then
            print('ctags command failed with exit code ' .. code)
        else
            print('ctags command succeeded')
        end
    end)
end

----------------自動標簽------------------
vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
        callback = function()
            local status = os.execute('rusty-tags -q vi')
            if status == 0 then
                find_cargo_and_tags_in_parents(vim.fn.expand('%:p:h'))
            else
                -- run_ctags(vim.fn.expand('%:p:h'))
            end
        end
    })

--------------自動保存---------------------
vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
        callback = function()
            vim.fn.execute('silent! write')
        end,
    })
