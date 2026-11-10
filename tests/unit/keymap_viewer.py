"""Stdlib checks; enable local Chromium checks with KEYMAP_VIEWER_BROWSER=1."""

import csv
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/keymap_viewer.py"
SPEC = importlib.util.spec_from_file_location("keymap_viewer", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
viewer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(viewer)


def mapping(**changes):
    row = dict.fromkeys(viewer.COLUMNS, "")
    row.update(
        mode="n",
        lhs="gg",
        scope="global",
        buffer="0",
        sid="-8",
        leader="\\",
        localleader="\\",
        **dict.fromkeys(viewer.FLAGS, "0"),
    )
    row.update(changes)
    return row


def csv_text(rows, header=None):
    stream = io.StringIO(newline="")
    writer = csv.writer(stream)
    writer.writerow(viewer.COLUMNS if header is None else header)
    writer.writerows([row[column] for column in viewer.COLUMNS] for row in rows)
    return stream.getvalue()


class GeneratorTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.source = self.root / "maps.csv"
        self.output = self.root / "maps.html"
        self.source.write_text(csv_text([mapping()]), encoding="utf-8")

    def test_bom_multiline_quotes_unicode_and_signed_sid(self):
        rows = [
            mapping(description='line one\r\n"quoted", 雪', sid=sid, line="12")
            for sid in ("-8", "0", "123", "")
        ]
        self.source.write_bytes(b"\xef\xbb\xbf" + csv_text(rows).encode())
        self.assertEqual(viewer.read_mappings(self.source), rows)

    def test_header_is_exact_including_order_and_duplicates(self):
        headers = [
            [],
            viewer.COLUMNS[:-1],
            viewer.COLUMNS + ["extra"],
            list(reversed(viewer.COLUMNS)),
            ["mode"] * len(viewer.COLUMNS),
        ]
        for header in headers:
            with self.subTest(header=header):
                self.source.write_text(csv_text([], header), encoding="utf-8")
                with self.assertRaisesRegex(ValueError, "header must be exactly"):
                    viewer.read_mappings(self.source)

    def test_row_schema(self):
        invalid = [
            (field, "")
            for field in ("mode", "lhs", "scope", "buffer", "leader", "localleader")
        ]
        invalid += [
            ("mode", "v"),
            ("scope", "local"),
            ("buffer", "-1"),
            ("buffer", "1"),
            ("scope", "buffer"),
            ("sid", "+2"),
            ("sid", "1.0"),
            ("sid", " 1"),
            ("line", "-1"),
            ("line", "１２"),
            ("buffer", "1.0"),
        ]
        invalid += [
            (field, value) for field in viewer.FLAGS for value in ("", "true", "2")
        ]
        for field, value in invalid:
            with self.subTest(field=field, value=value):
                self.source.write_text(
                    csv_text([mapping(**{field: value})]), encoding="utf-8"
                )
                with self.assertRaisesRegex(ValueError, "CSV record 2"):
                    viewer.read_mappings(self.source)
        for mode in "nxsoilct":
            row = mapping(mode=mode, scope="buffer", buffer="12")
            self.source.write_text(csv_text([row]), encoding="utf-8")
            self.assertEqual(viewer.read_mappings(self.source), [row])

    def test_rejects_malformed_csv(self):
        header = ",".join(viewer.COLUMNS) + "\n"
        for body in (
            'n,"unfinished',
            'n,g"g',
            'n,"gg"oops',
            "n,gg\n",
            csv_text([mapping()]).splitlines()[1] + ",extra\n",
            "\n",
        ):
            with self.subTest(body=body):
                self.source.write_text(header + body, encoding="utf-8")
                with self.assertRaises(ValueError):
                    viewer.read_mappings(self.source)

    def test_embedded_data_is_safe_and_placeholders_are_not_recursive(self):
        attack = "</script><script>globalThis.injected=1</script>&@@APP@@雪"
        rows = [mapping(description=attack, rhs="@@STYLE@@@@TOKENS@@@@DATA@@")]
        html = viewer.render_html(rows)
        match = re.search(
            r'<script id="mapping-data" type="application/json">(.*?)</script>',
            html,
            re.S,
        )
        assert match is not None
        data = match[1]
        self.assertEqual(json.loads(data), rows)
        self.assertNotIn("<", data)
        self.assertNotIn("&", data)
        self.assertNotIn(attack, html)
        self.assertEqual(html.count("<script"), 2)
        self.assertIn("@@STYLE@@@@TOKENS@@@@DATA@@", data)
        self.assertIn("connect-src 'none'", html)

    def test_generate_and_empty_snapshot(self):
        self.source.write_text(csv_text([]), encoding="utf-8")
        viewer.generate(self.source, self.output)
        self.assertIn('type="application/json">[]</script>', self.output.read_text())
        self.assertEqual(
            sorted(path.name for path in self.root.iterdir()), ["maps.csv", "maps.html"]
        )

    def test_atomic_failure_preserves_output_and_cleans_temporary(self):
        self.output.write_text("existing")
        with mock.patch.object(
            viewer.os, "replace", side_effect=OSError("replace denied")
        ):
            with self.assertRaisesRegex(OSError, "replace denied"):
                viewer.generate(self.source, self.output)
        self.assertEqual(self.output.read_text(), "existing")
        self.assertEqual(len(list(self.root.iterdir())), 2)
        self.source.write_text("bad header")
        with self.assertRaises(ValueError):
            viewer.generate(self.source, self.output)
        self.assertEqual(self.output.read_text(), "existing")
        with self.assertRaises(OSError):
            viewer.generate(self.root / "missing.csv", self.output)
        self.source.write_text(csv_text([mapping()]), encoding="utf-8")
        with self.assertRaises(OSError):
            viewer.generate(self.source, self.root / "missing" / "maps.html")

    def test_protects_input_samefile_and_symlinks(self):
        original = self.source.read_bytes()
        aliases = [self.source, self.root / "hard.csv", self.root / "sym.csv"]
        os.link(self.source, aliases[1])
        aliases[2].symlink_to(self.source)
        for output in aliases:
            with (
                self.subTest(output=output),
                self.assertRaisesRegex(ValueError, "different files"),
            ):
                viewer.generate(self.source, output)
        self.assertEqual(self.source.read_bytes(), original)

    def test_protects_generator_and_assets_including_aliases(self):
        asset = viewer.ASSETS / "tokens.js"
        alias = self.root / "asset.html"
        alias.symlink_to(asset)
        hard = self.root / "script.html"
        hard.symlink_to(SCRIPT)
        for output in (SCRIPT, asset, viewer.ASSETS / "new.html", alias, hard):
            with (
                self.subTest(output=output),
                self.assertRaisesRegex(ValueError, "source assets"),
            ):
                viewer.generate(self.source, output)
        assets = self.root / "assets"
        assets.mkdir()
        fixture = assets / "tokens.js"
        fixture.write_text("protected")
        linked = self.root / "hard.html"
        os.link(fixture, linked)
        with mock.patch.object(viewer, "ASSETS", assets):
            with self.assertRaisesRegex(ValueError, "source assets"):
                viewer.generate(self.source, linked)

    def test_output_symlink_is_replaced_not_followed(self):
        target = self.root / "target"
        target.write_text("do not overwrite")
        self.output.symlink_to(target)
        viewer.generate(self.source, self.output)
        self.assertFalse(self.output.is_symlink())
        self.assertEqual(target.read_text(), "do not overwrite")

    def test_cli_success_help_and_errors(self):
        def run(*args):
            return subprocess.run(
                [sys.executable, str(SCRIPT), *map(str, args)],
                capture_output=True,
                text=True,
            )

        self.assertEqual(run("--help").returncode, 0)
        self.assertEqual(run().returncode, 2)
        result = run(self.source, self.output)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.output.exists())
        for source, output in (
            (self.source, self.source),
            (self.root / "absent", self.output),
        ):
            result = run(source, output)
            self.assertEqual(result.returncode, 1)
            self.assertIn("keymap_viewer:", result.stderr)
            self.assertNotIn("Traceback", result.stderr)
        self.source.write_bytes(b"\xff")
        self.assertEqual(run(self.source, self.output).returncode, 1)


@unittest.skipUnless(
    os.environ.get("KEYMAP_VIEWER_BROWSER") == "1", "optional local Chromium checks"
)
class BrowserTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from playwright.sync_api import sync_playwright

        cls.playwright = sync_playwright().start()
        cls.browser = cls.playwright.chromium.launch(
            executable_path="/usr/bin/chromium", headless=True
        )

    @classmethod
    def tearDownClass(cls):
        cls.browser.close()
        cls.playwright.stop()

    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.page = self.browser.new_page()
        self.addCleanup(self.page.close)
        self.errors = []
        self.requests = []
        self.page.on("pageerror", lambda error: self.errors.append(str(error)))
        self.page.on("request", lambda request: self.requests.append(request.url))
        self.rows = [
            mapping(lhs=f"g{i:03}", description=f"entry {i}") for i in range(125)
        ]
        self.rows += [
            mapping(lhs="<C-X>f", rhs="control action"),
            mapping(lhs="<S-Tab>"),
            mapping(lhs="!"),
            mapping(lhs="<Plug>(Atlas)", rhs="plug action"),
            mapping(
                lhs="x", mode="i", scope="buffer", buffer="9", buffer_name="local.lua"
            ),
            mapping(lhs="z"),
            mapping(lhs="<NL>"),
            mapping(lhs="<C-I>"),
            mapping(lhs="<PageUp>"),
            mapping(lhs="<M-x>"),
            mapping(lhs="G"),
            mapping(
                lhs="evil",
                description='</script><img src="https://example.invalid/x" onerror="globalThis.injected=1">@@APP@@',
            ),
        ]
        self.open_rows(self.rows)

    def open_rows(self, rows):
        source, output = self.root / "maps.csv", self.root / "maps.html"
        source.write_text(csv_text(rows), encoding="utf-8")
        viewer.generate(source, output)
        self.page.goto(output.as_uri())
        self.page.wait_for_function(
            "document.querySelector('#total').textContent !== ''"
        )

    def count(self, expected):
        self.page.wait_for_function(
            "n => document.querySelector('#count').textContent.startsWith(n + ' /')",
            arg=expected,
        )

    def key(self, label):
        self.page.locator(f'#keyboard button[aria-label^="{label}:"]').click()

    def modifier(self, label):
        self.page.locator(
            f'#modifiers button[aria-label="Toggle {label} modifier"]'
        ).click()

    def test_prefix_selection_preserves_rows_and_pagination(self):
        self.count(len(self.rows))
        self.assertEqual(self.page.locator("#rows tr").count(), 100)
        self.page.locator("#next").click()
        self.assertIn("Page 2/2", self.page.locator("#page").inner_text())
        self.key("g")
        self.count(125)
        self.assertIn("Page 1/2", self.page.locator("#page").inner_text())
        self.page.locator("#rows button", has_text="g000").click()
        self.count(125)
        self.assertEqual(self.page.locator("#rows tr").count(), 100)
        self.assertEqual(
            self.page.locator("#breadcrumbs button").all_text_contents(), ["Root", "g"]
        )
        self.assertTrue(self.page.locator("#detail").is_visible())
        self.assertEqual(self.page.locator("#keyboard .traced").count(), 2)
        self.page.locator("#next").click()
        self.assertEqual(self.page.locator("#rows tr").count(), 25)
        self.page.locator("#back").click()
        self.count(len(self.rows))
        self.page.locator("#search").fill("entry 124")
        self.count(1)
        self.assertTrue(self.page.locator("#detail").is_hidden())
        self.assertEqual(self.page.locator("#keyboard .traced").count(), 0)

    def test_modifiers_shift_and_aliases(self):
        self.modifier("Ctrl")
        self.assertFalse(self.page.locator("#reset").is_disabled())
        self.page.locator("#reset").click()
        self.assertEqual(
            self.page.locator('#modifiers [aria-pressed="true"]').count(), 0
        )
        for modifier, key, expected in (
            ("Ctrl", "Ctrl+x", "<C-X>f"),
            ("Shift", "Shift+Tab", "<S-Tab>"),
            ("Shift", "Shift+1", "!"),
            ("Alt", "Alt+x", "<M-x>"),
            ("Shift", "Shift+g", "G"),
            ("Ctrl", "Ctrl+j", "<NL>"),
            ("Ctrl", "Tab", "<C-I>"),
        ):
            with self.subTest(modifier=modifier, key=key):
                self.modifier(modifier)
                self.key(key)
                self.count(1)
                self.assertEqual(
                    self.page.locator("#rows button").inner_text(), expected
                )
                self.assertEqual(
                    self.page.locator('#modifiers [aria-pressed="true"]').count(), 0
                )
                self.page.locator("#reset").click()
        self.key("PgUp")
        self.count(1)
        self.assertEqual(self.page.locator("#rows button").inner_text(), "<PageUp>")

    def test_combined_filters_empty_detail_and_nonphysical_tokens(self):
        self.page.locator("#mode").select_option("i")
        self.page.locator("#scope").select_option("buffer")
        self.page.locator("#buffer").select_option("9")
        self.count(1)
        self.page.locator("#rows button").click()
        self.assertEqual(self.page.locator("#fields dt").count(), len(viewer.COLUMNS))
        self.page.locator("#search").fill("does not exist")
        self.count(0)
        self.assertTrue(self.page.locator("#empty").is_visible())
        self.assertTrue(self.page.locator("#detail").is_hidden())
        for select in ("mode", "scope", "buffer"):
            self.page.locator(f"#{select}").select_option("")
        self.page.locator("#search").fill("")
        self.count(len(self.rows))
        self.page.locator("#continuations button", has_text="<Plug> ·").click()
        self.count(1)
        self.page.locator("#rows button").click()
        self.assertIn("<Plug>(Atlas)", self.page.locator("#detail-title").inner_text())
        self.page.locator("#reset").click()
        self.key("z")
        self.count(1)
        self.page.locator("#rows button").click()
        self.assertIn("(empty)", self.page.locator("#fields dd").all_text_contents())
        self.open_rows([])
        self.count(0)
        self.assertTrue(self.page.locator("#detail").is_hidden())
        self.assertTrue(self.page.locator("#next").is_disabled())

    def test_no_injection_or_external_requests(self):
        self.page.locator("#search").fill("@@APP@@")
        self.count(1)
        self.page.locator("#rows button").click()
        self.assertIn("</script>", self.page.locator("#fields").inner_text())
        self.assertIsNone(self.page.evaluate("globalThis.injected"))
        self.assertEqual(self.page.locator("img").count(), 0)
        self.assertEqual(self.errors, [])
        self.assertTrue(
            all(url.startswith("file:") for url in self.requests), self.requests
        )

    def test_token_identity(self):
        pairs = [
            ("<CR>", "<Enter>"),
            ("<C-M>", "<CR>"),
            ("<C-I>", "<Tab>"),
            ("<C-[>", "<Esc>"),
            ("<C-H>", "<BS>"),
            ("<NL>", "<C-J>"),
            ("<M-x>", "<A-x>"),
            ("<S-a>", "A"),
            ("<S-1>", "!"),
            ("<lt>", "<"),
            ("<Bar>", "|"),
            ("<PgUp>", "<PageUp>"),
        ]
        for left, right in pairs:
            self.assertTrue(
                self.page.evaluate(
                    "([a,b]) => KeyTokens.parse(a)[0].id === KeyTokens.parse(b)[0].id",
                    [left, right],
                ),
                (left, right),
            )
        self.assertFalse(
            self.page.evaluate(
                "KeyTokens.parse('<NL>')[0].id === KeyTokens.parse('<CR>')[0].id"
            )
        )

    def test_real_runtime_csv(self):
        source = Path("/tmp/ictye-nvim-keymaps.csv")
        if not source.exists():
            self.skipTest("real runtime CSV not present")
        rows = viewer.read_mappings(source)
        self.assertGreater(len(rows), 500)
        self.open_rows(rows)
        self.count(len(rows))
        seen = 0
        while True:
            seen += self.page.locator("#rows tr").count()
            if self.page.locator("#next").is_disabled():
                break
            self.page.locator("#next").click()
        self.assertEqual(seen, len(rows))
        self.assertEqual(self.errors, [])
        self.assertTrue(all(url.startswith("file:") for url in self.requests))


if __name__ == "__main__":
    unittest.main()
