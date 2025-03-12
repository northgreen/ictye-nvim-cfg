local log = nil -- mabye it will be used later

---@type LuaLogOutputter
local nvim_notify_outputter = {
    name = "vim",
    formatter = nil,
    output = function(self, msg, opt)
        local formatter = self.formatter
		if opt == nil then opt = {} end
        if opt and opt.formatter ~= nil then formatter = opt.formatter end

		---@type string
        local msg_str = nil
        if formatter then
            msg_str = formatter:format(msg, opt.formatter_opt)
        else
            msg_str = msg.msg
        end

        if msg.level == 0 then
            vim.notify(msg_str, vim.log.levels.DEBUG)
        elseif msg.level == 1 then
            vim.notify(msg_str, vim.log.levels.INFO)
        elseif msg.level == 2 then
            vim.notify(msg_str, vim.log.levels.WARN)
        elseif msg.level == 3 then
            vim.notify(msg_str, vim.log.levels.ERROR)
        elseif msg.level == 4 then
            vim.notify(msg_str, vim.log.levels.ERROR)
        end
    end
}

return function (log_module)
	log = log_module
	if log == nil then
		return
	end
	return nvim_notify_outputter
end
