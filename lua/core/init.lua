local ploadmodule = require 'util.module_load_utils'.ploadmodule

ploadmodule 'core.vimconfig'
ploadmodule 'core.keymap' .setup_keymap()
ploadmodule 'core.autocommand_set'
ploadmodule 'core.highlights'
ploadmodule 'core.lsp_project'
ploadmodule 'core.lsp'

if vim.g.neovide then
    ploadmodule 'core.neovide'
end
