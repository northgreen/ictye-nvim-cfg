// Scenario: LSP responsiveness on a TypeScript file (vtsls).
// Known case from the perf report: vtsls attach ~320ms but documentSymbol
// ~1100ms and edit is the slowest of all languages. Assert generous bounds.
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

const FIXTURE = new URL("../fixtures/typescript/test.ts", import.meta.url).pathname;

Deno.test({
  name: "perf: TypeScript (vtsls) attach / request / edit timings",
  fn: async () => {
    await withConfigNeovim({
      fn: async ({ reader, writer }) => {
        await using host = new Neovim(reader, writer);
        await waitForPlugins(host);

        // First open is the cold LSP attach for this server.
        const attach = await measureLspAttach(host, FIXTURE);
        assert(
          attach.ms < 30000,
          `TS LSP attach took ${attach.ms.toFixed(0)}ms (expected < 30s)`,
        );

        const symbols = await measureLspRequest(host, "textDocument/documentSymbol");
        assert(
          symbols.has && !symbols.err,
          `documentSymbol failed: ${JSON.stringify(symbols)}`,
        );
        assert(
          symbols.ms < 10000,
          `documentSymbol took ${symbols.ms.toFixed(0)}ms (expected < 10s)`,
        );

        const edit = await measureEdit(host, 300);
        assert(
          edit < 500,
          `inserting 300 chars took ${edit.toFixed(1)}ms (expected < 500ms)`,
        );

        console.log(
          `  verified: attach=${attach.ms.toFixed(0)}ms (${attach.client}), ` +
            `documentSymbol=${symbols.ms.toFixed(1)}ms, edit(300) = ${edit.toFixed(1)}ms`,
        );
      },
    });
  },
});
