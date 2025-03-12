return {
    "Freed-Wu/rime.nvim",
	enabled = false,
	opts = {},
    config = function(_,opt)
        require('rime.nvim').setup(opt)
    end
}
