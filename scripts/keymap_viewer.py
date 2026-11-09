#!/usr/bin/env python3
"""Generate a self-contained keyboard explorer from a Neovim keymap CSV."""

import argparse
import csv
import json
import os
from pathlib import Path
import re
import sys
import tempfile

COLUMNS = (
    "mode,lhs,rhs,description,callback,scope,buffer,buffer_name,filetype,sid,"
    "source,line,expr,noremap,silent,nowait,script,leader,localleader"
).split(",")
FLAGS = ("expr", "noremap", "silent", "nowait", "script")
ASSETS = Path(__file__).resolve().with_name("keymap_viewer_assets")


def checked_lines(stream):
    """csv.strict also accepts stray quotes in bare fields; reject those here."""
    state = "start"
    for number, line in enumerate(stream, 1):
        for char in line:
            if state == "quoted":
                if char == '"':
                    state = "closed"
            elif state == "closed":
                if char == '"':
                    state = "quoted"
                elif char in ",\r\n":
                    state = "start"
                else:
                    raise ValueError(
                        f"CSV line {number}: unexpected character after closing quote"
                    )
            elif char == '"':
                if state != "start":
                    raise ValueError(f"CSV line {number}: quote inside unquoted field")
                state = "quoted"
            elif char in ",\r\n":
                state = "start"
            else:
                state = "bare"
        yield line
    if state == "quoted":
        raise ValueError("CSV: unterminated quoted field")


def validate_row(row, number):
    def fail(message):
        raise ValueError(f"CSV record {number}: {message}")

    for name in ("mode", "lhs", "scope", "buffer", "leader", "localleader"):
        if not row[name]:
            fail(f"{name} is required")
    if row["mode"] not in tuple("nxsoilct"):
        fail("mode must be one of n,x,s,o,i,l,c,t")
    if row["scope"] not in ("global", "buffer"):
        fail("scope must be global or buffer")
    for name in FLAGS:
        if row[name] not in ("0", "1"):
            fail(f"{name} must be 0 or 1")
    for name in ("buffer", "sid", "line"):
        value = row[name]
        if not value and name != "buffer":
            continue
        pattern = r"-?[0-9]+" if name == "sid" else r"[0-9]+"
        if not re.fullmatch(pattern, value):
            fail(
                f"{name} must be {'a signed' if name == 'sid' else 'a nonnegative'} integer"
            )
    if (int(row["buffer"]) == 0) != (row["scope"] == "global"):
        fail("global scope requires buffer 0; buffer scope requires a positive buffer")
    return row


def read_mappings(path):
    csv.field_size_limit(sys.maxsize)
    with Path(path).open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.reader(checked_lines(stream), strict=True)
        try:
            header = next(reader, None)
            if header != COLUMNS:
                raise ValueError("CSV header must be exactly: " + ",".join(COLUMNS))
            mappings = []
            for number, cells in enumerate(reader, 2):
                if len(cells) != len(COLUMNS):
                    raise ValueError(
                        f"CSV record {number}: expected {len(COLUMNS)} fields, got {len(cells)}"
                    )
                mappings.append(validate_row(dict(zip(COLUMNS, cells)), number))
            return mappings
        except csv.Error as error:
            raise ValueError(f"CSV line {reader.line_num}: {error}") from error


def render_html(mappings):
    # Escape HTML parser delimiters even inside application/json script elements.
    data = (
        json.dumps(mappings, ensure_ascii=True)
        .replace("<", "\\u003c")
        .replace(">", "\\u003e")
        .replace("&", "\\u0026")
    )
    template = (ASSETS / "viewer.html").read_text(encoding="utf-8")
    replacements = {
        "STYLE": (ASSETS / "viewer.css").read_text(encoding="utf-8"),
        "TOKENS": (ASSETS / "tokens.js").read_text(encoding="utf-8"),
        "APP": (ASSETS / "viewer.js").read_text(encoding="utf-8"),
        "DATA": data,
    }
    return re.sub(
        r"@@(STYLE|TOKENS|APP|DATA)@@", lambda match: replacements[match[1]], template
    )


def same_file(left, right):
    return left.resolve() == right.resolve() or (
        left.exists() and right.exists() and os.path.samefile(left, right)
    )


def check_output_path(source, output):
    if same_file(source, output):
        raise ValueError("input and output must be different files")
    protected = [Path(__file__).resolve(), *ASSETS.rglob("*")]
    if output.resolve().is_relative_to(ASSETS.resolve()) or any(
        path.is_file() and same_file(path, output) for path in protected
    ):
        raise ValueError("output must not overwrite the generator or its source assets")


def generate(source, output):
    source, output = Path(source), Path(output)
    check_output_path(source, output)
    html = render_html(read_mappings(source))
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", newline="\n", dir=output.parent, delete=False
        ) as stream:
            temporary = Path(stream.name)
            stream.write(html)
        os.replace(temporary, output)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "input", type=Path, help="runtime keymaps CSV (UTF-8; BOM accepted)"
    )
    parser.add_argument("output", type=Path, help="standalone offline HTML file")
    arguments = parser.parse_args()
    try:
        generate(arguments.input, arguments.output)
    except (OSError, UnicodeError, ValueError) as error:
        parser.exit(1, f"keymap_viewer: {error}\n")


if __name__ == "__main__":
    main()
