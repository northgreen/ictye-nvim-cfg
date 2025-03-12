return {
    'rcarriga/nvim-dap-ui',
    lazy = true,
	cmd = {'DapNew'},
    config = function(_, opts)
        require("dapui").setup(opts)
        if options.ui.dapui.autoopen then
            require('dap').listeners.before.attach.dapui_config = function()
                require('dapui').open()
            end
            require('dap').listeners.before.launch.dapui_config = function()
                require('dapui').open()
            end
        end
        if options.ui.dapui.autoclose then
            require('dap').listeners.before.event_terminated.dapui_config =
                function() require('dapui').close() end
            require('dap').listeners.before.event_exited.dapui_config =
                function() require('dapui').close() end
        end
    end,
    dependencies = {'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio'}
}
