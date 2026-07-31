// Scenario: LSP server attaches to a buffer and responds to requests.
// Uses vim.lsp.buf_request (async) + polling to avoid blocking the main loop,
// which would deadlock the rpc channel.
import { assert } from "@std/assert";
import { Neovim } from "/denops-private/host/nvim.ts";
import { withConfigNeovim } from "../with_config.ts";
import { lua, waitForPlugins, waitFor } from "../util.ts";

Deno.test({
  name: "lsp: Lua LSP attaches and responds to documentSymbol",
  fn: async () => {
    await withConfigNeovim({
      fn: async ({ reader, writer }) => {
        await using host = new Neovim(reader, writer);
        await waitForPlugins(host);

        // Open a Lua file (lua_ls + null-ls attach here; .luarc.json pins the
        // workspace root to fixtures/lua so lua_ls does not scan the whole repo)
        await lua(host, "vim.api.nvim_command('edit " + new URL("../fixtures/lua/test.lua", import.meta.url).pathname + "')");

        // Wait for at least one LSP client
        await waitFor(host, async () => {
          const n = await lua<number>(host, "#vim.lsp.get_clients()");
          return n > 0;
        }, { timeout: 20000, label: "LSP clients" });

        const clients = await lua<{ name: string }[]>(
          host,
          "vim.tbl_map(function(c) return { name = c.name } end, vim.lsp.get_clients())",
        );
        assert(clients.length > 0, `no LSP client attached: ${JSON.stringify(clients)}`);

        // Fire async documentSymbol, store into a global, poll for completion.
        // (luaeval accepts an expression only — wrap side effects in an IIFE.)
        await lua(
          host,
          "(function() vim.g.test_symbols = nil; vim.lsp.buf_request(0, 'textDocument/documentSymbol', { textDocument = { uri = vim.uri_from_bufnr(0) } }, function(err, result) if not err and result then vim.g.test_symbols = #result else vim.g.test_symbols = -1 end end); return true end)()",
        );
        await waitFor(host, async () => {
          // msgpack encodes Lua nil as null, so check the condition in Lua.
          return await lua<boolean>(host, "vim.g.test_symbols ~= nil");
        }, { timeout: 15000, label: "documentSymbol response" });

        const symbols = await lua<number>(host, "vim.g.test_symbols");
        assert(
          symbols > 0,
          `documentSymbol returned ${symbols} symbols (expected > 0)`,
        );

        console.log(`  verified: LSP clients=${clients.map((c) => c.name).join(",")}, symbols=${symbols}`);
      },
    });
  },
});
