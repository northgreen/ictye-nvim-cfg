// Scenario: startup timing for full vs lite mode.
// The `spawn -> rpc ready` interval is a proxy for config-load time plus the
// framework's cli.ts boot; lite mode must be substantially faster.
import { assert } from "@std/assert";
import { Neovim } from "/denops-private/host/nvim.ts";
import { withConfigNeovim } from "../with_config.ts";
import { lua, waitForLua } from "../util.ts";

async function bootTiming(
  label: string,
  opts: { preCmd?: string[] },
): Promise<{ rpcMs: number; lazyMs: number }> {
  return await withConfigNeovim({
    ...opts,
    fn: async ({ reader, writer, startTime }) => {
      await using host = new Neovim(reader, writer);
      const rpcMs = Date.now() - startTime;
      const lazyT0 = Date.now();
      await waitForLua(host, "package.loaded['lazy'] ~= nil", {
        timeout: 30000,
        label: "lazy loaded",
      });
      const lazyMs = Date.now() - lazyT0;
      const colors = await lua<string | null>(host, "vim.g.colors_name");
      console.log(
        `  ${label}: spawn→rpc=${rpcMs}ms, rpc→lazy=${lazyMs}ms, colorscheme=${colors}`,
      );
      return { rpcMs, lazyMs };
    },
  });
}

Deno.test({
  name: "perf: full mode boots and becomes interactive",
  fn: async () => {
    const t = await bootTiming("full", {});
    assert(t.rpcMs < 10000, `full spawn→rpc took ${t.rpcMs}ms (expected < 10s)`);
    assert(t.lazyMs < 10000, `full rpc→lazy took ${t.lazyMs}ms (expected < 10s)`);
  },
});

Deno.test({
  name: "perf: lite mode boots (must be much faster than full)",
  fn: async () => {
    const t = await bootTiming("lite", { preCmd: ["let g:lite_mode=v:true"] });
    assert(t.rpcMs < 5000, `lite spawn→rpc took ${t.rpcMs}ms (expected < 5s)`);
    assert(t.lazyMs < 5000, `lite rpc→lazy took ${t.lazyMs}ms (expected < 5s)`);
  },
});
