"""Run with python3 -B tests/unit/pref_converter.py; no third-party Python modules."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from pref import pref2speedscope as converter


class ConverterTests(unittest.TestCase):
    def test_speedscope_stack_order_metadata_and_weights(self):
        data = converter.convert(
            ["main.lua:1;@child.lua:2:3 4", "main.lua:1;@child.lua:2:3 6"]
        )
        profile = data["profiles"][0]
        self.assertEqual(profile["samples"], [[0, 1]])
        self.assertEqual(profile["weights"], [10])
        self.assertEqual(profile["endValue"], 10)
        self.assertEqual(
            data["shared"]["frames"][1],
            {"name": "@child.lua:2:3", "file": "child.lua", "line": 2, "col": 3},
        )
        self.assertEqual(
            converter.parse_samples(["child.lua:2;main.lua:1 4"], "leaf-first")[0][
                "frames"
            ],
            ["main.lua:1", "child.lua:2"],
        )

    def test_symbol_and_windows_source_metadata(self):
        for raw in ("[string]:123", "@0xabc", "pcall"):
            self.assertEqual(converter.parse_frame(raw), {"name": raw})
        frame = converter.parse_frame("C:\\src\\file.lua:12:8")
        self.assertEqual(
            (frame["file"], frame["line"], frame["col"]), ("C:\\src\\file.lua", 12, 8)
        )

    def test_perfanno_paths_unknown_frames_and_total_counts(self):
        with tempfile.TemporaryDirectory() as directory:
            samples = converter.parse_samples(
                [
                    "root.lua:10;@0xabc;sub/../a b.lua:20:3 5",
                    "[string]:12;pcall 2",
                    "root.lua:10;a b.lua:20 3",
                ]
            )
            text, unresolved = converter.convert_to_perfanno(samples, directory)
            self.assertEqual(
                text,
                f"{directory}/root.lua:10;{directory}/a b.lua:20 8\n[unresolved] 2\n",
            )
            self.assertEqual(unresolved, {"@0xabc", "[string]:12", "pcall"})

    def test_invalid_input_fails_with_line_number(self):
        for line in (
            "broken",
            "a.lua:1 -1",
            "a.lua:1 0",
            "a.lua:1 1.5",
            "a.lua:1 ²",
            ";a.lua:1 3",
        ):
            with self.subTest(line=line), self.assertRaisesRegex(ValueError, "line 2"):
                converter.parse_samples(["a.lua:1 1", line])
        with self.assertRaisesRegex(ValueError, "no samples"):
            converter.parse_samples(["\n"])

    def test_cli_compatibility_stdin_and_explicit_errors(self):
        with tempfile.TemporaryDirectory() as directory:
            source, output = Path(directory) / "in.log", Path(directory) / "out.json"
            source.write_text("main.lua:1;child.lua:2 7\n", encoding="utf-8")
            script = ROOT / "pref/pref2speedscope.py"
            for output_args in ([str(output)], ["-o", str(output)]):
                subprocess.run(
                    [
                        sys.executable,
                        "-B",
                        str(script),
                        str(source),
                        *output_args,
                    ],
                    check=True,
                    capture_output=True,
                )
                self.assertEqual(
                    json.loads(output.read_text())["profiles"][0]["endValue"], 7
                )
            run = subprocess.run(
                [
                    sys.executable,
                    "-B",
                    str(script),
                    "--format",
                    "perfanno",
                    "--source-root",
                    directory,
                ],
                input=source.read_text(),
                text=True,
                capture_output=True,
                check=True,
            )
            self.assertIn(
                f"{directory}/main.lua:1;{directory}/child.lua:2 7", run.stdout
            )
            run = subprocess.run(
                [sys.executable, "-B", str(script), str(source)],
                text=True,
                capture_output=True,
            )
            self.assertEqual(run.returncode, 0)
            self.assertIn("shared", json.loads(run.stdout))
            output.write_text("keep me", encoding="utf-8")
            source.write_text("invalid\n", encoding="utf-8")
            run = subprocess.run(
                [
                    sys.executable,
                    "-B",
                    str(script),
                    str(source),
                    str(output),
                ],
                text=True,
                capture_output=True,
            )
            self.assertNotEqual(run.returncode, 0)
            self.assertIn("line 1", run.stderr)
            self.assertEqual(output.read_text(), "keep me")

    def test_perfanno_native_loader(self):
        plugin = Path(
            os.environ.get(
                "PERFANNO_PATH", Path.home() / ".local/share/nvim/lazy/perfanno.nvim"
            )
        )
        if not plugin.is_dir():
            self.skipTest("set PERFANNO_PATH to test the real installed plugin")
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            main, leaf = root / "main.lua", root / "child with space.lua"
            main.write_text("-- root\n", encoding="utf-8")
            leaf.write_text("-- leaf\n", encoding="utf-8")
            samples = converter.parse_samples(
                [f"{main}:1;@0xabc;{leaf}:2 4", "[string]:123 2"]
            )
            text, _ = converter.convert_to_perfanno(samples)
            (root / "perf.log").write_text(text, encoding="utf-8")
            driver = root / "check.lua"
            driver.write_text(
                """
vim.opt.rtp:prepend(vim.env.PERFANNO_PATH)
local perf = require('perfanno')
perf.setup({annotate_after_load=false, annotate_on_open=false})
vim.cmd('PerfLoadFlameGraph')
local cg = require('perfanno.callgraph').callgraphs.time
assert(cg.total_count == 6, vim.inspect(cg))
local root, leaf = vim.env.PROFILE_ROOT..'/main.lua', vim.env.PROFILE_ROOT..'/child with space.lua'
assert(cg.node_info[root][1].count == 4)
assert(cg.node_info[leaf][2].count == 4)
assert(cg.node_info[root][1].out_counts[leaf][2] == 4)
assert(cg.node_info[leaf][2].in_counts[root][1] == 4)
print('PASS: native PerfLoadFlameGraph counts, source locations and caller direction')
vim.cmd('qa!')
""",
                encoding="utf-8",
            )
            env = dict(os.environ, PERFANNO_PATH=str(plugin), PROFILE_ROOT=directory)
            run = subprocess.run(
                [
                    os.environ.get("NVIM", "nvim"),
                    "--headless",
                    "-u",
                    "NONE",
                    "-l",
                    str(driver),
                ],
                cwd=directory,
                env=env,
                text=True,
                capture_output=True,
                timeout=20,
            )
            self.assertEqual(run.returncode, 0, run.stdout + run.stderr)
            self.assertIn("PASS:", run.stdout + run.stderr)


if __name__ == "__main__":
    unittest.main()
