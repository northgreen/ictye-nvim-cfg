// Opt-in integration test against a real C# project; edits stay in memory.
import { assert } from "@std/assert";
import { Neovim } from "/denops-private/host/nvim.ts";
import { withConfigNeovim } from "../with_config.ts";
import { lua, waitFor, waitForPlugins } from "../util.ts";

const source = Deno.env.get("NVIM_ROSLYN_TEST_FILE");
Deno.test({
  name: "roslyn: diagnostics appear and clear without manual InsertLeave fanout",
  ignore: !source,
  fn: async () => {
    await withConfigNeovim({
      fn: async ({ reader, writer }) => {
        await using host = new Neovim(reader, writer);
        await waitForPlugins(host);
        await lua(host, `(function() vim.cmd('edit ' .. vim.fn.fnameescape(${JSON.stringify(source)})); return true end)()`);
        await waitFor(host, async () => await lua<boolean>(host,
          "#vim.lsp.get_clients({bufnr=0,name='roslyn'}) > 0"),
          { timeout: 30000, label: "Roslyn attach" });
        await waitFor(host, async () => await lua<boolean>(host,
          "vim.fn.execute('messages'):find('Roslyn project initialization complete',1,true) ~= nil"),
          { timeout: 30000, label: "Roslyn project initialization" });
        await lua(host, "(function() _G.roslyn_test_buf=vim.api.nvim_get_current_buf(); _G.roslyn_test_lines=vim.api.nvim_buf_get_lines(0,0,-1,false); return true end)()");
        try {
          const manual = await lua<number>(host, "(function() local count=0; for _,a in ipairs(vim.api.nvim_get_autocmds({event={'InsertLeave','BufWritePost'}})) do if a.desc=='roslyn_ls: refresh diagnostics' then count=count+1 end end; return count end)()");
          assert(manual === 0, `manual cross-buffer refresh remains: ${manual}`);
          const immediate = await lua<number>(host, "(function() local c=vim.lsp.get_clients({bufnr=roslyn_test_buf,name='roslyn'})[1]; local request=c.request; local count=0; c.request=function(self,method,...) if method=='textDocument/diagnostic' then count=count+1 end; return request(self,method,...) end; local ok,err=pcall(vim.api.nvim_exec_autocmds,'InsertLeave',{buffer=roslyn_test_buf,modeline=false}); c.request=request; assert(ok,err); return count end)()");
          assert(immediate === 0, `InsertLeave issued ${immediate} redundant diagnostic requests`);
          await lua(host, "(function() vim.api.nvim_buf_set_lines(roslyn_test_buf,-1,-1,false,{'class NvimDiagnosticRegressionProbe { MissingTypeForNvimRegression field; }'}); return true end)()");
          const hasError = "vim.iter(vim.diagnostic.get(roslyn_test_buf)):any(function(d) return d.message:find('MissingTypeForNvimRegression',1,true)~=nil end)";
          await waitFor(host, async () => await lua<boolean>(host, hasError),
            { timeout: 30000, label: "compiler diagnostic appears" });
          await lua(host, "(function() vim.api.nvim_buf_set_lines(roslyn_test_buf,0,-1,false,roslyn_test_lines); vim.bo[roslyn_test_buf].modified=false; return true end)()");
          await waitFor(host, async () => await lua<boolean>(host, `not (${hasError})`),
            { timeout: 30000, label: "compiler diagnostic clears" });
        } finally {
          await lua(host, "(function() if vim.api.nvim_buf_is_valid(roslyn_test_buf) then vim.api.nvim_buf_set_lines(roslyn_test_buf,0,-1,false,roslyn_test_lines); vim.bo[roslyn_test_buf].modified=false end; return true end)()");
        }
      },
    });
  },
});
