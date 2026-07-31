// Scenario: core keymaps defined in lua/core/keymap/init.lua actually exist.
import { assertEquals } from "@std/assert";
import { Neovim } from "/denops-private/host/nvim.ts";
import { withConfigNeovim } from "../with_config.ts";
import { lua, waitForPlugins } from "../util.ts";

interface Keymap {
  mode: string;
  lhs: string;
  desc?: string;
}

async function findMapping(
  host: Neovim,
  mode: string,
  lhs: string,
): Promise<Keymap | undefined> {
  const maps = await lua<Keymap[]>(
    host,
    `vim.tbl_map(function(m) return { mode = m.mode, lhs = m.lhs, desc = m.desc } end, vim.api.nvim_get_keymap('${mode}'))`,
  );
  return maps.find((m) => m.lhs === lhs);
}

Deno.test({
  name: "keymaps: core mappings registered",
  fn: async () => {
    await withConfigNeovim({
      fn: async ({ reader, writer }) => {
        await using host = new Neovim(reader, writer);
        await waitForPlugins(host);

        // leader is unset in the config, so nvim's default `\` applies;
        // <leader>q expands to the actual key sequence in nvim_get_keymap.
        const leader = (await lua<string>(host, "vim.g.mapleader")) || "\\";
        const closeBuf = await findMapping(host, "n", `${leader}q`);
        assertEquals(
          closeBuf !== undefined,
          true,
          `<leader>q (close buffer) missing (leader='${leader}')`,
        );

        // jj = exit insert mode
        const jj = await findMapping(host, "i", "jj");
        assertEquals(jj !== undefined, true, "jj (exit insert) missing");

        // <C-x>f = file picking via mini.files.
        // nvim_get_keymap serializes control keys as literal `<C-X>f`.
        const filePick = await findMapping(host, "n", "<C-X>f");
        assertEquals(
          filePick !== undefined,
          true,
          "<C-x>f (mini.files) missing",
        );

        console.log(`  verified: <leader>q (leader='${leader}'), jj, <C-x>f`);
      },
    });
  },
});
