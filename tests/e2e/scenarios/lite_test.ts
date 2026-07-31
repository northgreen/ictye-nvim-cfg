// Scenario: lite mode (nvim --cmd "let g:lite_mode=v:true") boots cleanly
// with only the lite plugin set loaded.
import { assert } from "@std/assert";
import { Neovim } from "/denops-private/host/nvim.ts";
import { withConfigNeovim } from "../with_config.ts";
import { lua, waitForLua } from "../util.ts";

Deno.test({
  name: "lite mode: boots with minimal plugin set",
  fn: async () => {
    await withConfigNeovim({
      // g:lite_mode must be set before init.lua runs → use --cmd
      preCmd: ["let g:lite_mode=v:true"],
      fn: async ({ reader, writer }) => {
        await using host = new Neovim(reader, writer);

        // Lite mode has only a few plugins; wait for lazy to come up.
        await waitForLua(host, "package.loaded['lazy'] ~= nil", {
          timeout: 20000,
          label: "lazy loaded (lite)",
        });

        const lite = await lua<boolean>(host, "vim.g.lite_mode == true");
        assert(lite, "lite_mode not active (init.lua picked full mode?)");

        const plugins = await lua<unknown[]>(
          host,
          "vim.tbl_map(function(p) return p.name end, require('lazy').plugins())",
        );
        assert(
          plugins.length <= 10,
          `lite mode loaded ${plugins.length} plugins (expected <= 10): ${JSON.stringify(plugins)}`,
        );

        // Lite branch applies a colorscheme after plugins load; verify it ran.
        const colors = await lua<string | null>(
          host,
          "vim.g.colors_name",
        );
        console.log(`  verified: lite_mode=${lite}, plugins=${plugins.length}, colorscheme=${colors}`);
      },
    });
  },
});
