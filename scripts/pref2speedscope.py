#!/usr/bin/env python3
"""Convert LuaJIT jit.p G-mode stacks to Speedscope JSON or PerfAnno perf.log."""

import argparse
import json
from pathlib import Path
import re
import sys


SOURCE_RE = re.compile(r"^(.+?):(\d+)(?::(\d+))?$")


def parse_frame(raw):
    """Keep unresolved symbols, including anonymous chunks, out of source metadata."""
    frame = {"name": raw}
    match = SOURCE_RE.fullmatch(raw)
    if match and not raw.startswith(("[", "@0x")):
        file, line, col = match.groups()
        frame.update(file=file.removeprefix("@"), line=int(line))
        if col:
            frame["col"] = int(col)
    return frame


def parse_samples(lines, stack_order="root-first"):
    """G-mode uses caller-first stacks; other dumps can explicitly request reversal."""
    samples = []
    for linenr, line in enumerate(lines, 1):
        if not line.strip():
            continue
        try:
            stack, count = line.rstrip().rsplit(None, 1)
            if not count.isascii() or not count.isdecimal() or int(count) <= 0:
                raise ValueError("sample count must be a positive integer")
            frames = stack.split(";")
            if any(not frame.strip() for frame in frames):
                raise ValueError("empty stack frame")
        except ValueError as error:
            raise ValueError(f"line {linenr}: invalid folded stack: {error}") from error
        if stack_order == "leaf-first":
            frames.reverse()
        samples.append({"frames": frames, "weight": int(count)})
    if not samples:
        raise ValueError("profile contains no samples")
    return samples


def convert_to_speedscope(samples, profile_name="pref.log", parse_frames=True):
    """Deduplicate stacks without expanding weighted samples into individual events."""
    frames, frame_index, stacks = [], {}, {}
    for sample in samples:
        indices = []
        for name in sample["frames"]:
            if name not in frame_index:
                frame_index[name] = len(frames)
                frames.append(parse_frame(name) if parse_frames else {"name": name})
            indices.append(frame_index[name])
        key = tuple(indices)
        stacks[key] = stacks.get(key, 0) + sample["weight"]
    return {
        "$schema": "https://www.speedscope.app/file-format-schema.json",
        "profiles": [
            {
                "type": "sampled",
                "name": profile_name,
                "unit": "none",
                "startValue": 0,
                "endValue": sum(stacks.values()),
                "samples": [list(stack) for stack in stacks],
                "weights": list(stacks.values()),
            }
        ],
        "shared": {"frames": frames},
    }


def convert(lines, profile_name="pref.log", parse_frames=True):
    """Compatibility entry point for the original Speedscope converter."""
    return convert_to_speedscope(parse_samples(lines), profile_name, parse_frames)


def convert_to_perfanno(samples, source_root=None):
    """Emit PerfLoadFlameGraph input with canonical source paths and no symbol prefixes."""
    root = Path(source_root or Path.cwd()).expanduser().resolve()
    stacks, unresolved = {}, set()
    for sample in samples:
        locations = []
        for raw in sample["frames"]:
            frame = parse_frame(raw)
            if "file" not in frame or frame["line"] <= 0:
                unresolved.add(raw)
                continue
            path = Path(frame["file"]).expanduser()
            path = (root / path).resolve()
            if any(char in str(path) for char in (";", "\n", "\r")):
                raise ValueError(
                    f"source path cannot be represented in folded format: {path}"
                )
            locations.append(f"{path}:{frame['line']}")
        # PerfAnno's native loader cannot represent symbols without file:line.
        # An empty-source trace still contributes to its total sample count.
        stack = ";".join(locations) or "[unresolved]"
        stacks[stack] = stacks.get(stack, 0) + sample["weight"]
    return "".join(f"{stack} {count}\n" for stack, count in stacks.items()), unresolved


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", nargs="?", help="Input log; omitted or - reads stdin")
    parser.add_argument(
        "output_path", nargs="?", help="Output file (legacy positional form)"
    )
    parser.add_argument(
        "-o", "--output", help="Output file; omitted or - writes stdout"
    )
    parser.add_argument(
        "--format", choices=("speedscope", "perfanno"), default="speedscope"
    )
    parser.add_argument(
        "--raw", action="store_true", help="Speedscope: omit structured source metadata"
    )
    parser.add_argument(
        "--source-root",
        help="PerfAnno: base directory for relative source paths (default: cwd)",
    )
    parser.add_argument(
        "--stack-order",
        choices=("root-first", "leaf-first"),
        default="root-first",
        help="Input order; jit.p G-mode is root-first (default)",
    )
    args = parser.parse_args(argv)
    if args.output and args.output_path:
        parser.error("specify output only once (positional or --output)")
    if args.raw and args.format != "speedscope":
        parser.error("--raw is only supported for Speedscope")
    if args.source_root and args.format != "perfanno":
        parser.error("--source-root is only supported for PerfAnno")
    try:
        if args.input and args.input != "-":
            with open(args.input, encoding="utf-8") as stream:
                samples = parse_samples(stream, args.stack_order)
        else:
            samples = parse_samples(sys.stdin, args.stack_order)
        if args.format == "perfanno":
            result, unresolved = convert_to_perfanno(samples, args.source_root)
            if unresolved:
                print(
                    f"PerfAnno: omitted {len(unresolved)} unresolved frame names; sample weights preserved",
                    file=sys.stderr,
                )
        else:
            result = (
                json.dumps(
                    convert_to_speedscope(
                        samples, args.input or "pref.log", not args.raw
                    ),
                    ensure_ascii=False,
                    indent=2,
                )
                + "\n"
            )
        output = args.output or args.output_path
        if output and output != "-":
            with open(output, "w", encoding="utf-8") as stream:
                stream.write(result)
        else:
            sys.stdout.write(result)
    except (OSError, ValueError) as error:
        parser.exit(1, f"{parser.prog}: {error}\n")


if __name__ == "__main__":
    main()
