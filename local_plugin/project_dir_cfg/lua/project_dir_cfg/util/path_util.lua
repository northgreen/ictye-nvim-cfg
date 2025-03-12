local M = {}

local config = require("project_dir_cfg.config")
local os = require("project_dir_cfg.util.os")
local uv = vim.uv

if vim.fn.has('win32') == 1 then
    M.sep = '\\'
else
    M.sep = '/'
end

M.datapath = vim.fn.stdpath("data") -- directory
M.datapath = M.datapath .. "/project_nvim" -- directory
M.historyfile = M.datapath .. "/project_history" -- file

function M.init()
    M.datapath = require("project_dir_cfg.config").options.datapath
    M.datapath = M.datapath .. "/project_nvim" -- directory
    M.historyfile = M.datapath .. "/project_history" -- file
end

function M.create_datadir(callback)
    if callback ~= nil then -- async
        uv.fs_mkdir(M.datapath, 448, callback)
    else -- sync
        uv.fs_mkdir(M.datapath, 448)
    end
end

function M.is_excluded(dir)
    for _, dir_pattern in ipairs(config.options.exclude_dirs) do
        if dir:match(dir_pattern) ~= nil then return true end
    end

    return false
end

function M.exists(path) return vim.fn.empty(vim.fn.glob(path)) == 0 end

---normalizes the path to the current OS
---@param path string
---@return string
function M.normal_path(path)
    path = path:gsub('[\\/]+', M.sep) -- replace all backslashes with forward slashes

    local parts = {}
    for part in path:gmatch("[^" .. M.sep .. "]+") do
        if part == ".." then
            if #parts > 0 then table.remove(parts) end
        elseif part ~= "." then
            table.insert(parts, part)
        end
    end

    local normalized_path = table.concat(parts, M.sep)

    if path:sub(1, 1) == M.sep then
        normalized_path = M.sep .. normalized_path
    end

	-- replace drive letter with uppercase on Windows
	if os.is_windows then
		local dirve_letter = normalized_path:match('^%a:')
		if dirve_letter then
			normalized_path = dirve_letter:upper() .. normalized_path:sub(3)
		end
	end

    return normalized_path
end

function M.file_exists(path) return vim.fn.filereadable(path) == 1 end

function M.dir_exists(path) return vim.fn.isdirectory(path) == 1 end


--- get absolute path from relative path or current directory if path is nil
--- @param path string
--- @return string
function M.abs_path(path)
    if not path then return uv.cwd() end

    if path:sub(1, 1) == "~" then
        local home = uv.os_homedir()
        path = home .. path:sub(2)
    end

    path = M.normal_path(path)

    if path:sub(1, 1) == "/" then return path end

    local cwd = vim.loop.cwd()
    return M.normal_path(cwd .. "/" .. path)
end

function M.dir_name(path) return vim.fs.dirname(path) end

M.join = vim.fs.joinpath

return M
