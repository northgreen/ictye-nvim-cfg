// Helpers for driving nvim over the rpc channel.
import { Neovim } from "/denops-private/host/nvim.ts";

/** Evaluate a Lua expression in nvim and return the result. */
export function lua<T>(host: Neovim, expr: string): Promise<T> {
  return host.call("luaeval", `(${expr})`) as Promise<T>;
}

// ---- Timing helpers (measure inside nvim with vim.loop.hrtime for precision) ----

interface LspAttachResult {
  ms: number;
  client: string;
}

/**
 * Open a file and measure how long the first LSP client takes to attach
 * (via a one-shot LspAttach autocmd installed before the edit).
 * Poll `vim.g.attach_ms` for the result.
 */
export async function measureLspAttach(
  host: Neovim,
  file: string,
): Promise<LspAttachResult> {
  const fileLit = JSON.stringify(file);
  await lua(
    host,
    `(function()
      local t0 = vim.loop.hrtime()
      vim.g.attach_ms = nil
      vim.api.nvim_create_autocmd('LspAttach', {
        once = true,
        callback = function(args)
          local c = vim.lsp.get_clients({ bufnr = args.buf })[1]
          vim.g.attach_ms = { ms = (vim.loop.hrtime() - t0) / 1e6, client = c and c.name or 'unknown' }
        end,
      })
      vim.api.nvim_command('edit ' .. vim.fn.fnameescape(${fileLit}))
      return true
    end)()`,
  );
  await waitFor(host, () => lua<boolean>(host, "vim.g.attach_ms ~= nil"), {
    timeout: 30000,
    label: `LSP attach for ${file}`,
  });
  return await lua<LspAttachResult>(host, "vim.g.attach_ms");
}

interface LspRequestResult {
  ms: number;
  err: string | null;
  has: boolean;
}

/**
 * Measure the round-trip of a textDocument/* LSP request from inside nvim.
 */
export async function measureLspRequest(
  host: Neovim,
  method: string,
  clientName?: string,
): Promise<LspRequestResult> {
  const methodLit = JSON.stringify(method);
  const clientLit = clientName ? JSON.stringify(clientName) : "nil";
  await lua(
    host,
    `(function(method, clientName)
      local t0 = vim.loop.hrtime()
      vim.g.req_ms = nil
      local params
      if method == 'textDocument/documentSymbol' then
        params = { textDocument = { uri = vim.uri_from_bufnr(0) } }
      else
        params = { textDocument = { uri = vim.uri_from_bufnr(0) }, position = { line = 0, character = 0 } }
      end
      local function fire(bufnr)
        if clientName then
          local c = vim.lsp.get_clients({ name = clientName, bufnr = bufnr })[1]
          if c then
            c.request(method, params, function(err, result)
              vim.g.req_ms = {
                ms = (vim.loop.hrtime() - t0) / 1e6,
                err = err and err.message or nil,
                has = result ~= nil,
              }
            end, bufnr)
            return true
          end
          return false
        end
        vim.lsp.buf_request(bufnr, method, params, function(err, result)
          vim.g.req_ms = {
            ms = (vim.loop.hrtime() - t0) / 1e6,
            err = err and err.message or nil,
            has = result ~= nil,
          }
        end)
        return true
      end
      if not fire(0) and clientName then
        -- client not yet attached to this buffer; fall back to any buffer
        local c = vim.lsp.get_clients({ name = clientName })[1]
        if c then
          c.request(method, params, function(err, result)
            vim.g.req_ms = {
              ms = (vim.loop.hrtime() - t0) / 1e6,
              err = err and err.message or nil,
              has = result ~= nil,
            }
          end, 0)
        end
      end
      return true
    end)(${methodLit}, ${clientLit})`,
  );
  await waitFor(host, () => lua<boolean>(host, "vim.g.req_ms ~= nil"), {
    timeout: 30000,
    label: `${method} response`,
  });
  return await lua<LspRequestResult>(host, "vim.g.req_ms");
}

/** Measure inserting N characters into the current buffer (one set_text call each). */
export async function measureEdit(host: Neovim, n: number): Promise<number> {
  await lua(
    host,
    `(function(n)
      local t0 = vim.loop.hrtime()
      for i = 1, n do
        vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, { string.char(97 + (i % 26)) })
      end
      vim.g.edit_ms = (vim.loop.hrtime() - t0) / 1e6
      return true
    end)(${n})`,
  );
  return await lua<number>(host, "vim.g.edit_ms");
}

/** Poll until a predicate (any async checks) returns true. */
export async function waitFor(
  host: Neovim,
  cond: () => Promise<boolean>,
  { timeout = 30000, interval = 300, label = "condition" } = {},
): Promise<void> {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await cond()) {
      return;
    }
    await new Promise((r) => setTimeout(r, interval));
  }
  throw new Error(`waitFor timed out after ${timeout}ms: ${label}`);
}

/** Poll until a Lua expression is truthy. */
export async function waitForLua(
  host: Neovim,
  expr: string,
  { timeout = 30000, interval = 300, label = expr } = {},
): Promise<void> {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await lua<boolean>(host, expr)) {
      return;
    }
    await new Promise((r) => setTimeout(r, interval));
  }
  throw new Error(`waitForLua timed out after ${timeout}ms: ${label}`);
}

/** Wait for the user config's plugins to finish loading (lazy.nvim). */
export async function waitForPlugins(host: Neovim): Promise<void> {
  // lazy.nvim sets _lazy.healthy / marks plugins loaded; simplest stable
  // signal is a fixed settle window plus a probe that the config ran.
  console.log("  [wait] sleeping 4s");
  await new Promise((r) => setTimeout(r, 4000));
  console.log("  [wait] probing lazy");
  await waitForLua(
    host,
    "vim.g.loaded_plugins ~= nil or package.loaded['lazy'] ~= nil",
    { timeout: 20000, label: "lazy loaded" },
  );
  console.log("  [wait] lazy ready");
}
