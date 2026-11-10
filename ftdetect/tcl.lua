-- Tcl-family filetypes for tcl-lsp (Tk / Expect / F5 surfaces).
-- Deliberately excludes generic extensions (.test, .impl, .apl, .tm) so
-- unrelated projects keep their own filetypes.
local function shebang_is_tcl(bufnr)
  local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
  if not first:match("^#!") then
    return false
  end
  for _, word in ipairs({ "expect", "tclsh", "wish", "jimsh" }) do
    if first:find(word, 1, true) then
      return true
    end
  end
  return false
end

vim.filetype.add({
  extension = {
    tcl = "tcl",
    tk = "tcl",
    itcl = "tcl",
    exp = "tcl",
    expect = "tcl",
    irul = "tcl",
    irule = "tcl",
    irules = "tcl",
    iapp = "tcl",
    iappimpl = "tcl",
    tmsh = "tcl",
    tclspec = "tcl",
    sslictcl = "tcl",
  },
  pattern = {
    -- Scripts named by their interpreter instead of an extension
    -- (e.g. `mytool` starting with `#!/usr/bin/wish`).
    [".*"] = {
      function(_, bufnr)
        if shebang_is_tcl(bufnr) then
          return "tcl"
        end
      end,
      { priority = -math.huge },
    },
  },
})
