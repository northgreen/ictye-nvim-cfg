-- Some configuration must be set before Ionide starts
-- vim.g['fsharp#fsautocomplete_command'] = {
--   'dotnet',
--   'fsautocomplete'
-- }

return {
  -- F# support
  'ionide/Ionide-vim',
  enabled = false,
  -- ft = { 'fsharp', 'fsharp_project' },
  config = function()
    -- if you need extra configuration/events, example with 'Show tooltips on CursorHold'
    vim.api.nvim_create_autocmd({ 'CursorHold' }, {
      pattern = { '*.fs', '*.fsi', '*.fsx' },
      callback = function()
        vim.fn['fsharp#showTooltip']()
      end,
    })

    -- Show fsi in horizontal split
    -- vim.g["fsharp#fsi_window_command"] = "vnew"
  end
}
