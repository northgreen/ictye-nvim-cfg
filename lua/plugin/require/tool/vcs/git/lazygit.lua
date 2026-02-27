--- @return LazyPluginSpec
return {
    'kdheepak/lazygit.nvim',
    cmd = {
        'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter',
        'LazyGitFilterCurrentFile'
    },
    dependencies = {'nvim-lua/plenary.nvim'},
    keys = require("core.keymap").lazygit
}
