// Verify throttled rendering still reflects buffer and diagnostic changes.
import { assert } from "@std/assert";
import { Neovim } from "/denops-private/host/nvim.ts";
import { withConfigNeovim } from "../with_config.ts";
import { lua, waitFor, waitForPlugins } from "../util.ts";

Deno.test({
  name: "bufferline: coalesced redraw reflects add, diagnostics and delete",
  fn: async () => {
    await withConfigNeovim({
      fn: async ({ reader, writer }) => {
        await using host = new Neovim(reader, writer);
        await waitForPlugins(host);
        await lua(
          host,
          "(function() require('lazy').load({plugins={'bufferline.nvim'}}); return true end)()",
        );
        await lua(
          host,
          "(function() _G.ui_test_buf=vim.api.nvim_create_buf(true,false); vim.api.nvim_buf_set_name(ui_test_buf,'probe-ui'); vim.api.nvim_set_current_buf(ui_test_buf); _G.ui_test_ns=vim.api.nvim_create_namespace('bufferline-regression'); return true end)()",
        );
        try {
          await waitFor(
            host,
            async () =>
              await lua<boolean>(host, "nvim_bufferline():find('probe-ui',1,true) ~= nil"),
            { timeout: 3000, label: "new buffer tab" },
          );
          await lua(
            host,
            "(function() vim.diagnostic.set(ui_test_ns,ui_test_buf,{{lnum=0,col=0,message='test error',severity=vim.diagnostic.severity.ERROR}}); return true end)()",
          );
          await waitFor(
            host,
            async () =>
              await lua<boolean>(host, "nvim_bufferline():find('BufferLineError',1,true) ~= nil"),
            { timeout: 3000, label: "diagnostic count" },
          );
          await lua(
            host,
            "(function() vim.diagnostic.reset(ui_test_ns,ui_test_buf); vim.api.nvim_buf_delete(ui_test_buf,{force=true}); return true end)()",
          );
          await waitFor(
            host,
            async () =>
              await lua<boolean>(host, "nvim_bufferline():find('probe-ui',1,true) == nil"),
            { timeout: 3000, label: "deleted buffer removed" },
          );
          assert(
            await lua<boolean>(
              host,
              "vim.api.nvim_get_option_value('tabline',{}):find('nvim_bufferline',1,true) ~= nil",
            ),
          );
        } finally {
          await lua(
            host,
            "(function() if vim.api.nvim_buf_is_valid(ui_test_buf) then vim.api.nvim_buf_delete(ui_test_buf,{force=true}) end; return true end)()",
          );
        }
      },
    });
  },
});
