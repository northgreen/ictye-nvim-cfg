local config = require('project_dir_cfg.config')
local _log = require('project_dir_cfg.util.log')
local log = require('project_dir_cfg.util.log_util')

local M = {}
local module_name = 'project_dir_cfg.init'

local function auto_command_setup()
    _log.debug(module_name, 'setting up autocommands')
    local augroup_id = vim.api.nvim_create_augroup("project", {clear = true})

    if not config.options.manual_mode then
        vim.api.nvim_create_autocmd({'VimEnter', 'BufEnter'}, {
            group = augroup_id,
            pattern = '*',
            callback = require('project_dir_cfg.project').on_buf_enter
        })
    end

    vim.api.nvim_create_autocmd({'VimLeavePre'}, {
        group = augroup_id,
        pattern = '*',
        callback = require("project_dir_cfg.project.history").write_projects_to_history
    })

    vim.api.nvim_create_autocmd({'BufEnter'}, {
        group = augroup_id,
        pattern = '*',
        callback = require('project_dir_cfg.cfg').on_buf_enter
    })
end

function M.setup(opt)
    config.setup(opt)

    _log.setup({log_level = string.upper(config.options.log_level)})

    local vim_outputter = require("project_dir_cfg.util.log.nvim_output")(log)
    if not vim_outputter then vim_outputter = log.out_putters.std_outputter end
    log.setup({
        rotes = {
            root = {
                level = 0,
                output = vim_outputter,
                output_opt = {
                    formatter = log.formatters.simple_formatter,
                    formatter_opt = {show_debug_trace = true},
                    opt = {}
                }
            }
        }
    })


    local glob = require("project_dir_cfg.util.globtopattern")
    local home = vim.fn.expand("~")

    config.options.exclude_dirs = vim.tbl_map(function(pattern)
        if vim.startswith(pattern, "~/") then
            pattern = home .. "/" .. pattern:sub(3, #pattern)
        end
        return glob.globtopattern(pattern)
    end, config.options.exclude_dirs)

    vim.opt.autochdir = false -- implicitly unset autochdir

    require("project_dir_cfg.util.path_util").init()
    require("project_dir_cfg.project").init()

    auto_command_setup()
    require("project_dir_cfg.commands").setup()
end

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    print("Test Start")
    M.setup()
    local history = require("project_dir_cfg.project.history")
    print(vim.inspect(history.get_recent_projects()))
    print(vim.inspect(history.recent_projects))
end
return M
