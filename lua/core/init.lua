local ploadmodule = require 'util.module_load_utils'.ploadmodule

ploadmodule 'core.keymap'
ploadmodule 'core.vimconfig'
ploadmodule 'core.autocommand_set'
ploadmodule 'core.highlights'
ploadmodule 'core.lsp_project'
ploadmodule 'core.lsp'

if vim.g.neovide then
    ploadmodule 'core.neovide'
end
