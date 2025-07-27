if _G.configed[vim.bo.filetype] then return end
_G.configed[vim.bo.filetype] = true

require 'dap'.configurations.rust = {
    {
        type = 'codelldb',
        request = 'launch',
        name = 'Launch',
        program = function()
            return vim.fn.input('Path to executable: ',
                vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        initCommands = function()
            -- Find out where to look for the pretty printer Python module
            local rustc_sysroot = vim.fn.trim(vim.fn.system(
                'rustc --print sysroot'))

            local script_import = 'command script import "' .. rustc_sysroot ..
                '/lib/rustlib/etc/lldb_lookup.py"'
            local commands_file = rustc_sysroot ..
                '/lib/rustlib/etc/lldb_commands'
            local commands = {}
            local file = io.open(commands_file, 'r')
            if file then
                for line in file:lines() do
                    table.insert(commands, line)
                end
                file:close()
            end
            table.insert(commands, 1, script_import)
            return commands
        end
    }
}
