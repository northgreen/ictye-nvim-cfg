--- Log module for IcUtil.
local M = {}
--- @enum IcUtilLogLevel
M.levels = {DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3, FATAL = 4}

M.out_putters = {}
M.formatters = {}

---@param level integer
---@return string|nil
M.get_level_name = function(level)
    if level == M.levels.DEBUG then
        return "DEBUG"
    elseif level == M.levels.INFO then
        return "INFO"
    elseif level == M.levels.WARN then
        return "WARN"
    elseif level == M.levels.ERROR then
        return "ERROR"
    elseif level == M.levels.FATAL then
        return "FATAL"
    end
end

---@class LuaLogEvent
---@field name string
---@field level IcUtilLogLevel
---@field msg string
---@field time integer
---@field traceback string

---@class LuaLogFormaterOpt
---@field show_debug_trace boolean|nil

---@class LuaLogFormatter
---@field format fun(self: LuaLogFormatter, msg:LuaLogEvent, opt:LuaLogFormaterOpt|nil): string

---format log message with simple format
---@type LuaLogFormatter
M.formatters.simple_formatter = {
    format = function(_, msg, opt)
        if opt == nil then opt = {} end
        local level = M.get_level_name(msg.level)
        local time_str = os.date("%Y-%m-%d %H:%M:%S", msg.time)
        local msg_str = string.format("[%s %s] %s %s", msg.name, level,
                                      time_str, msg.msg)

        if opt.show_debug_trace and msg.traceback ~= nil and msg.level == 0 then
            msg_str = msg_str .. string.format("\n%s", msg.traceback)
        end

        return msg_str
    end
}

---@class LuaLogOutputterOpt
---@field formatter LuaLogFormatter
---@field formatter_opt LuaLogFormaterOpt|nil
---@field opt table

---out putter for log message
---@class LuaLogOutputter
---@field formatter LuaLogFormatter|nil
---@field output fun(self: LuaLogOutputter, msg:LuaLogEvent,opt:LuaLogOutputterOpt|nil)

--- output log message to stdio/stderr
---@type LuaLogOutputter
M.out_putters.std_outputter = {
    formatter = nil,
    output = function(self, msg, opt)
        local formatter = self.formatter
        if opt == nil then opt = {} end
        if opt and opt.formatter ~= nil then formatter = opt.formatter end

        -- format message
        local msg_str
        if formatter then
            msg_str = formatter:format(msg, opt.formatter_opt)
        else
            msg_str = msg.msg
        end

        -- output message
        if msg.level < 3 then
            io.write(msg_str .. "\n")
        else
            io.stderr:write(msg_str .. "\n")
        end
    end
}

---describe a rote
---it will rote some log message to `output` with `output_opt`
---@class LuaLogRoute
---@field level IcUtilLogLevel the level of log message that will be rote to `output`
---@field output LuaLogOutputter|string the outputter of log message. if it is a string, it will be used as the name of outputter in `outputs`
---@field output_opt LuaLogOutputterOpt the option of outputter

---@class LuaLogRotater
---@field rotes table<string,LuaLogRoute>
---@field outputs table<string,LuaLogOutputter>
---@field output fun(self: LuaLogRotater, msg:LuaLogEvent)
local roatter = {outputs = {root = M.out_putters.std_outputter}, rotes = {}}

function roatter:output(msg)
    local current_route = self.rotes[msg.name]
    if current_route == nil then current_route = self.rotes.root end
    if current_route == nil then return end
    if current_route.level > msg.level or M.levels[M.opt.log_level] > msg.level then
        return
    end

    if type(current_route.output) == 'table' then
        ---@diagnostic disable-next-line cannot-assign 
        current_route.output:output(msg, current_route.output_opt)
    else
        self.outputs[current_route.output].output(
            self.outputs[current_route.output], msg)
    end
end

---@class LuaLogger
---@field level IcUtilLogLevel unused field
---@field name string the name of logger
---@field parentLogger LuaLogger|nil the parent logger,it is unused now
---@field debug fun(self: LuaLogger, msg: any)|nil
---@field info fun(self: LuaLogger, msg: any)|nil
---@field warn fun(self: LuaLogger,msg: any)|nil
---@field error fun(self: LuaLogger,msg: any)|nil
---@field fatal fun(self: LuaLogger,msg: any)|nil

---@param self LuaLogger
---@param msg string
---@param level IcUtilLogLevel
local function _log(self, msg, level)
    local msg_str = tostring(msg)
    ---@type LuaLogEvent
    local logevent = {
        name = self.name,
        traceback = debug.traceback('', 2),
        msg = msg_str,
        level = level,
        time = os.time()
    }
    roatter:output(logevent)
end

---Root Logger
---@type LuaLogger
local RootLogger = {
    name = 'ROOT',
    level = 0,
    parentLogger = nil,
    debug = function(self, msg) _log(self, msg, 0) end,
    info = function(self, msg) _log(self, msg, 1) end,
    warn = function(self, msg) _log(self, msg, 2) end,
    error = function(self, msg) _log(self, msg, 3) end,
    fatal = function(self, msg) _log(self, msg, 4) end
}

---mata table for IcLogger
M.show_debug_trace = true
---@type metatable
local logger_mt = {__index = RootLogger}

---get logger by name
---@param name string
---@return LuaLogger
function M.getLogger(name)
    if name == nil then
        return setmetatable({parentLogger = RootLogger}, logger_mt)
    else
        return setmetatable({name = name, parentLogger = RootLogger}, logger_mt)
    end
end

---opt for log module
---@class LuaLogOpt
---@field log_level string|nil 
---@field rotes table<string,LuaLogRoute>|nil the routes of log,will rote log message to different outputter. you can also use `root` to set default outputter.
---@field outputs table<string,LuaLogOutputter>|nil define outputter by name.it will be used in `rotes`
---@field show_debug_trace boolean|nil
M.opt = {
    log_level = "INFO",
    rotes = {
        root = {
            name = 'root',
            output_opt = {
                formatter = M.formatters.simple_formatter,
                formatter_opt = {show_debug_trace = M.show_debug_trace},
                opt = {}
            },
            level = 0,
            output = M.out_putters.std_outputter
        }
    },
    outputs = {std = M.out_putters.std_outputter},
    show_debug_trace = false
}

local function deep_copy(orig)
    if type(orig) ~= 'table' then return orig end
    local visited = {}
    local function copy(obj)
        if type(obj) ~= 'table' then return obj end
        if visited[obj] then return visited[obj] end
        local new_table = {}
        visited[obj] = new_table
        for k, v in pairs(obj) do new_table[copy(k)] = copy(v) end
        local mt = getmetatable(obj)
        if mt ~= nil then setmetatable(new_table, copy(mt)) end
        return new_table
    end
    return copy(orig)
end

local function merge_tables(target, source)
    local merged = deep_copy(target)
    for k, v in pairs(source) do
        if type(v) == 'table' and type(merged[k]) == 'table' then
            merged[k] = merge_tables(merged[k], v)
        else
            merged[k] = deep_copy(v)
        end
    end
    return merged
end

local function deep_extend(...)
    local result = {}
    for _, t in ipairs({...}) do
        if type(t) ~= 'table' then
            error("Unable to extend non-table type.")
        end
        result = merge_tables(result, t)
    end
    return result
end

---Init log module with config.
---@param cfg LuaLogOpt|nil
function M.setup(cfg)
    M.opt = deep_extend(M.opt, cfg or {})

    -- set roatter
    roatter.rotes = M.opt.rotes
    roatter.outputs = M.opt.outputs
end

return M
