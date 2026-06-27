return {
    'chipsenkbeil/distant.nvim',
    enabled=false,
    branch = 'v0.3',
    config = function()
        require('distant'):setup()
    end
}
