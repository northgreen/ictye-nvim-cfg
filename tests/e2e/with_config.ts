// E2E test harness: launches real nvim WITH the user config loaded and
// communicates over msgpack-rpc through a small deno relay process.
//
// This is adapted from denops.vim's own testutil (tests/denops/testutil/),
// with the key difference: `--clean` is removed so the user's real config
// (~/.config/nvim/init.lua) is loaded, enabling true end-to-end tests of
// keymaps, LSP, and plugin behavior.
import { channel } from "@core/streamutil";
import { tap } from "@milly/streams/transform/tap";
import { ADDR_ENV_NAME } from "/denops-testutil/cli.ts";

const script = new URL(
  "./vendor/denops.vim/tests/denops/testutil/cli.ts",
  import.meta.url,
);
const origLog = console.log.bind(console);
const origError = console.error.bind(console);
const noop = () => {};

export type Fn<T> = (helper: {
  reader: ReadableStream<Uint8Array>;
  writer: WritableStream<Uint8Array>;
  stdout: ReadableStream<string>;
  stderr: ReadableStream<string>;
  /** Unix epoch ms when the nvim process was spawned. */
  startTime: number;
}) => T;

export interface WithConfigOptions<T> {
  fn: Fn<T>;
  /** Print nvim's stderr/stdout (very noisy with a real config). */
  verbose?: boolean;
  /** Commands run via `--cmd`, BEFORE the user config (vimrc) loads. */
  preCmd?: string[];
  /** Vim commands executed BEFORE the user config loads. */
  prelude?: string[];
  /** Vim commands executed after the rpc channel is up. */
  postlude?: string[];
  /** Extra environment variables. */
  env?: Record<string, string>;
  /** Additional CLI args (e.g. ["-u", "NONE"] to skip the user config). */
  extraArgs?: string[];
}

export function withConfigNeovim<T>(
  options: WithConfigOptions<T>,
): Promise<Awaited<T>> {
  const exec = Deno.execPath();
  const commands = [
    ...(options.prelude ?? []),
    "let g:denops_test_channel = jobstart(" +
      `  ['${exec}', 'run', '--allow-all', '${script}'],` +
      `  {'rpc': v:true}` +
      ")",
    ...(options.postlude ?? []),
  ];
  const args = [
    ...(options.preCmd ?? []).flatMap((c) => ["--cmd", c]),
    "--headless",
    "-n", // Disable swap file
    "-V1", // Verbose level 1 (Echo messages to stderr)
    "-c",
    "set columns=9999", // Avoid unwilling output newline
    ...commands.flatMap((c) => ["-c", c]),
    ...(options.extraArgs ?? []),
  ];
  return withProcess("nvim", args, options);
}

async function withProcess<T>(
  cmd: string,
  args: string[],
  { fn, env, verbose }: WithConfigOptions<T>,
): Promise<Awaited<T>> {
  const aborter = new AbortController();
  const { signal } = aborter;
  const listener = Deno.listen({
    hostname: "127.0.0.1",
    port: 0, // Automatically select free port
  });

  const command = new Deno.Command(cmd, {
    args,
    stdin: "piped",
    stdout: "piped",
    stderr: "piped",
    env: {
      ...env,
      [ADDR_ENV_NAME]: JSON.stringify(listener.addr),
    },
    signal,
  });
  const proc = command.spawn();
  const startTime = Date.now();

  let stdout = proc.stdout.pipeThrough(new TextDecoderStream(), { signal });
  let stderr = proc.stderr.pipeThrough(new TextDecoderStream(), { signal });
  if (verbose) {
    stdout = stdout.pipeThrough(tap((s) => origLog(s)));
    stderr = stderr.pipeThrough(tap((s) => origError(s)));
  }
  const { writer: stdoutWriter, reader: stdoutReader } = channel<string>();
  stdout.pipeTo(stdoutWriter).catch(noop);
  const { writer: stderrWriter, reader: stderrReader } = channel<string>();
  stderr.pipeTo(stderrWriter).catch(noop);

  const conn = await listener.accept();
  try {
    return await fn({
      reader: conn.readable,
      writer: conn.writable,
      stdout: stdoutReader,
      stderr: stderrReader,
      startTime,
    });
  } finally {
    listener.close();
    try {
      aborter.abort("withProcess disposed");
    } catch {
      // Already exited, do nothing.
    }
    await Promise.all([
      proc.stdin.close(),
      proc.status,
    ]);
    await Promise.all([
      proc.stdout.cancel(),
      proc.stderr.cancel(),
    ]);
  }
}
