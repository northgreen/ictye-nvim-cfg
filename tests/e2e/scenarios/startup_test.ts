// Scenario: the user config loads cleanly in full mode.
import { assertEquals, assert } from "@std/assert";
import { Neovim } from "/denops-private/host/nvim.ts";
import { withConfigNeovim } from "../with_config.ts";
import { lua, waitForPlugins } from "../util.ts";

Deno.test({
  name: "full mode: config loads, lazy.nvim present, colorscheme applied",
  fn: async () => {
    await withConfigNeovim({
      fn: async ({ reader, writer, stderr }) => {
        await using host = new Neovim(reader, writer);
        console.log("  [1] host up");
        await waitForPlugins(host);
        console.log("  [2] plugins settled");

        // The user's init.lua actually ran. Full mode: g:lite_mode is unset.
        const mode = await lua<boolean>(host, "vim.g.lite_mode == nil");
        assert(mode, "expected full mode (g:lite_mode unset)");

        // lazy.nvim bootstrapped (100+ plugins in full mode).
        const lazyLoaded = await lua<boolean>(
          host,
          "package.loaded['lazy'] ~= nil",
        );
        assert(lazyLoaded, "lazy.nvim should be loaded in full mode");

        // A colorscheme was applied by the config.
        const scheme = await lua<string>(host, "vim.g.colors_name or ''");
        assert(scheme !== "", `expected a colorscheme, got '${scheme}'`);
        console.log(`  colorscheme: ${scheme}`);

        // No fatal errors on stderr (E5107/E117/stack tracebacks).
        const { value: errTail } = await stderr.getReader().read();
        const text = errTail ?? "";
        const fatal = text.match(
          /Error detected while processing|E\d{3,4}:.*(?:error|failed)|stack traceback/i,
        );
        assertEquals(fatal, null, `fatal stderr output: ${text.slice(0, 500)}`);
      },
    });
  },
});
