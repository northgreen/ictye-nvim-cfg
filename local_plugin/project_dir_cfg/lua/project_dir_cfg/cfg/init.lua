local M = {}

local buf_util = require('project_dir_cfg.util.buf_util')
local path = require('project_dir_cfg.util.path_util')
local project = require('project_dir_cfg.project')
local log = require('project_dir_cfg.util.log')
local module_name = 'project_dir_cfg.cfg'
local uv = vim.uv

M.cur_project_config = {}

---open project config file in the specified mode.
---@param mode string|integer
---@param callback function
---@return nil|integer file descriptor
local function open_config_file(mode, callback)
    if callback then
        uv.fs_open(M.get_cfg_file_path(), mode, 438, callback)
    else
        return uv.fs_open(M.get_cfg_file_path(), mode, 438)
    end
end

---A function to write a gitignore file in the configuration directory.
local function write_git_ignore()
    uv.fs_open(path.join(M.get_cfg_dir(), ".gitignore"), "w", 438,
               function(err, fd)
        if fd then
            uv.fs_write(fd, "*\n!.gitignore\n")
            uv.fs_close(fd)
        else
            log.error(module_name, "Failed to open gitignore file:" ..
                          M.get_cfg_dir() .. "because of:" .. err)
        end
    end)
end

---Create project configuration directory
---@param callback function|nil
local function create_config_dir(callback)
    if callback then
        uv.fs_mkdir(M.get_cfg_dir(), 448, callback)
    else
        uv.fs_mkdir(M.get_cfg_dir(), 448)
    end
end

--- Get the configuration directory of the current project.
--- @return string
function M.get_cfg_dir()
    if not project.last_project then return "" end
    local proje_dir = project.last_project
    return path.join(proje_dir, ".nvim_proj")
end

---get the configuration file path of the current project.
---@return string
function M.get_cfg_file_path()
    if not project.last_project then return "" end
    return path.join(M.get_cfg_dir(), "config.json")
end

--- Load the configuration of the current project.
--- @return nil
function M.load_config()
    if not path.exists(M.get_cfg_file_path()) then return end
    open_config_file('r', function(err, fd)
        if fd then
            uv.fs_fstat(fd, function(err, stat)
                if stat ~= nil then
                    uv.fs_read(fd, stat.size, -1, function(err, data)
                        if data then
                            M.cur_project_config = vim.json.decode(data)
                            uv.fs_close(fd)
                        else
                            log.error(module_name,
                                      "Failed to read config file:" ..
                                          M.get_cfg_file_path() .. "because:" ..
                                          err)
                        end
                    end)
                else
                    log.error(module_name, "Failed to read config file:" ..
                                  M.get_cfg_file_path() .. ",because of:" .. err)
                end
            end)
        else
            log.error(module_name, "Failed to open config file:" ..
                          M.get_cfg_file_path() .. "because of:" .. err)
        end
    end)
end

--- Write the configuration of the current project.
--- @return nil
function M.write_config()
    if M.cur_project_config == {} then return end

    -- create config directory if not exists,and set mode for write
    local mode = 'w'
    if not path.exists(M.get_cfg_dir()) then
        create_config_dir()
        mode = 'w+'
        write_git_ignore()
    elseif not path.exists(M.get_cfg_file_path()) then
        mode = 'w+'
    end

    open_config_file(mode, function(_, fd)
        if fd then
            uv.fs_write(fd, vim.json.encode(M.cur_project_config))
            uv.fs_close(fd)
        else
            log.error(module_name,
                      "Failed to write config file:" .. M.get_cfg_file_path())
        end
    end)
end

function M.on_buf_enter()
    if buf_util.buf_is_file() then
        log.debug(module_name, "on_buf_enter")
        M.load_config()
    end
end

function M.on_buf_exit()
    if buf_util.buf_is_file() and M.cur_project_config ~= {} then
        M.write_config()
    end
end

return M
