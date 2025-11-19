return {
    "keaising/im-select.nvim",
    enabled = false,
	event = {"BufReadPre"},
    opts = {
        default_im_select = "1033",
        default_command = "im-select.exe",
        set_default_events = {
            "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave"
        },
        set_previous_events = {"InsertEnter"},
        keep_quiet_on_no_binary = false,
        async_switch_im = true
    }
}
