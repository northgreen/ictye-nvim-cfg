// Scenario: LSP responsiveness on a Lua file (lua_ls + null-ls).
// Measures attach latency, documentSymbol/hover round-trips, and edit cost.
// Asserts generous sanity bounds to catch regressions, prints measured values.
import { assert } from "@std/assert";
import { Neovim } from "/denops-private/host/nvim.ts";
import { withConfigNeovim } from "../with_config.ts";
import {
  lua,
  measureEdit,
  measureLspAttach,
  measureLspRequest,
  waitForPlugins,
} from "../util.ts";

const FIXTURE = new URL("../fixtures/lua/test.lua", import.meta.url).pathname;

Deno.test({
  name: "perf: Lua LSP attach / request / edit timings",
  fn: async () => {
    await withConfigNeovim({
      fn: async ({ reader, writer }) => {
        await using host = new Neovim(reader, writer);
        await waitForPlugins(host);

        // First open is the cold LSP attach for this server.
        const attach = await measureLspAttach(host, FIXTURE);
        assert(
          attach.ms < 20000,
          `Lua LSP attach took ${attach.ms.toFixed(0)}ms (expected < 20s)`,
        );

        const symbols = await measureLspRequest(
          host,
          "textDocument/documentSymbol",
          "lua_ls",
        );
        assert(
          symbols.has && !symbols.err,
          `documentSymbol failed: ${JSON.stringify(symbols)}`,
        );
        assert(
          symbols.ms < 5000,
          `documentSymbol took ${symbols.ms.toFixed(0)}ms (expected < 5s)`,
        );

        const hover = await measureLspRequest(host, "textDocument/hover", "lua_ls");
        assert(
          hover.ms < 5000,
          `hover took ${hover.ms.toFixed(0)}ms (expected < 5s)`,
        );

        const edit = await measureEdit(host, 300);
        assert(
          edit < 200,
          `inserting 300 chars took ${edit.toFixed(1)}ms (expected < 200ms)`,
        );

        console.log(
          `  verified: attach=${attach.ms.toFixed(0)}ms (${attach.client}), ` +
            `documentSymbol=${symbols.ms.toFixed(1)}ms, ` +
            `hover=${hover.ms.toFixed(1)}ms, edit(300) = ${edit.toFixed(1)}ms`,
        );
      },
    });
  },
});
