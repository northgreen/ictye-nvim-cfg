--- @return LazyPluginSpec
return {
    'rcarriga/nvim-dap-ui',
    lazy = true,
	cmd = {'DapNew'},
	opts = {},
    config = function(_, opts)
        local dapui = require('dapui')
        local dap = require('dap')

        dapui.setup(opts)
        if options.ui.dapui.autoopen then
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
        end
        if options.ui.dapui.autoclose then
            dap.listeners.before.event_terminated.dapui_config =
                function() dapui.close() end
            dap.listeners.before.event_exited.dapui_config =
                function() dapui.close() end
        end
    end,
    dependencies = {'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio'}
}
