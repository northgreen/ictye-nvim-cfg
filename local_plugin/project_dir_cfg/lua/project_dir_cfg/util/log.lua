--- Log module for IcUtil.
local M = {}
local notify = vim.notify
local vim_levels = vim.log.levels
M.show_debug_trace = true
M.levels = {DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3, FATAL = 4}
M.log_level = M.levels.DEBUG


---@class IcLogOpt
---@field log_level string
M.opt = {log_level = "DEBUG", rotes = {}, outputs = {}}

---convert anything to string
---@param msg any
---@return string
function M.message_to_string(msg)
    if msg == nil then
        return ""
    elseif type(msg) == "table" then
        return vim.inspect(msg)
    elseif type(msg) == "string" then
        return msg
    else
        return tostring(msg)
    end
end

---format log message
---@param time integer
---@param name string
---@param level string
---@param msg string
---@return string
local function format(time, name, level, msg)
    return string.format("[%s] %s %s:%s", os.date("%Y-%m-%d %H:%M:%S", time),
                         level, name, msg)
end

---output log message
---@param msg string
---@param level IcUtilLogLevel
local function log_out(msg, level)
    local function do_fun()
        if level == M.levels.DEBUG then
            notify(msg, vim_levels.DEBUG)
        elseif level == M.levels.INFO then
            notify(msg, vim_levels.INFO)
        elseif level == M.levels.WARN then
            notify(msg, vim_levels.WARN)
        elseif level == M.levels.ERROR then
            notify(msg, vim_levels.ERROR)
        elseif level == M.levels.FATAL then
            notify(msg, vim_levels.ERROR)
        end
    end
    if not coroutine.running() then
        vim.schedule(do_fun)
    else
        do_fun()
    end
end

---output debug message
---@param name string
---@param msg any
function M.debug(name, msg)
    if M.log_level > M.levels.DEBUG then return end
    local msg_str = M.message_to_string(msg)
    log_out(format(os.time(), name, "DEBUG", msg_str), M.levels.DEBUG)
end

---output debug message with traceback,it is suitable for debugging
---may be it is sound strange,isn't it?
---but i think u can use it for some(many) special cases.
---@param name string
---@param msg any
function M.debug_onece(name, msg)
    if M.log_level > M.levels.DEBUG then return end
    local msg_str = M.message_to_string(msg)
    local traceback = "\\n"

    if M.show_debug_trace then
        traceback = traceback .. debug.traceback("Debug Location:", 2)
    end
    log_out(format(os.time(), name, "DEBUG", msg_str) .. traceback,
            M.levels.DEBUG)
end

---output info message
---@param name string
---@param msg any
function M.info(name, msg)
    if M.log_level > M.levels.INFO then return end
    local msg_str = M.message_to_string(msg)
    log_out(format(os.time(), name, "INFO", msg_str), M.levels.INFO)
end

---output warning message
---@param name string
---@param msg any
function M.warn(name, msg)
    if M.log_level > M.levels.WARN then return end
    local msg_str = M.message_to_string(msg)
    log_out(format(os.time(), name, "WARN", msg_str), M.levels.WARN)
end

---output error message
---@param name string
---@param msg any
function M.error(name, msg)
    if M.log_level > M.levels.ERROR then return end
    local msg_str = M.message_to_string(msg)
    log_out(format(os.time(), name, "ERROR", msg_str), M.levels.ERROR)
end

---output fatal message
---@param name string
---@param msg any
function M.fatal(name, msg)
    if M.log_level > M.levels.FATAL then return end
    local msg_str = M.message_to_string(msg)
    log_out(format(os.time(), name, "FATAL", msg_str), M.levels.FATAL)
end

function M.log_traceback(name)
    log_out(debug.traceback("[" .. name .. "]" .. "Traceback:", 2),
            M.levels.DEBUG)
end

---@param cfg IcLogOpt
function M.setup(cfg) M.log_level = M.levels[cfg.log_level] end

return M
