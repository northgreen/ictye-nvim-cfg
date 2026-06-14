(local Autocmd vim.api.nvim_create_autocmd)
{
:setup (fn []
  ; deleat sda file 
  (Autocmd :VimLeave 
    {:callback (fn []
      (local data-path (vim.fn.stdpath :data))
        (local sdata-path
          (vim.fs.joinpath (tostring data-path)
            :shada :main.shada.tmp.X))
          (when (= (vim.fn.filereadable sdata-path) 1)
                (vim.fn.delete sdata-path)))
          :pattern "*"})

  ; save session on leave
  (Autocmd :VimLeavePre
    {:callback (fn []
      (local resession (require :resession))
      (resession.save :last))})

  ; Oil rename hook
  (Autocmd :User
    {:callback (fn [event]
      (when (= (. event.data.actions 1 :type)
                :move)
        (Snacks.rename.on_rename_file (. event.data.actions 1 :src_url)
          (. event.data.actions 1 :dest_url))))
      :pattern :OilActionsPost})

  ; enable treesister every buffer
  (Autocmd :BufReadPost
    {:callback (fn [] 
      (let [bufnr (vim.api.nvim_get_current_buf)
            lang   vim.bo.filetype]
        (when (and lang (vim.treesitter.get_parser bufnr lang))
        (vim.treesitter.start bufnr lang))))})	

  (Autocmd :BufRead
    {:callback (fn [args]
      (local line-count
              (vim.api.nvim_buf_line_count args.buf))
      (when (> line-count 5000)
        (collectgarbage :stop)
        (vim.defer_fn (fn []
            (collectgarbage :restart)
            (collectgarbage :collect))
          1000)))}))
}
