#!/usr/bin/env python3
"""Real Kitty/Nvim/icat/browser acceptance test. No network pages are opened.
Run from the repository: python3 tests/unit/kitty_terminal_host.py
Requires Kitty remote control with screenshot support and ImageMagick for pixel evidence.
Only the explicitly created Kitty window is closed on failure.
"""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[2]
ARTIFACTS = Path(tempfile.mkdtemp(prefix="kitty-lua-terminal-host-"))
CLASS = "kitty-lua-terminal-test-" + ARTIFACTS.name.rsplit("-", 1)[-1]
window_id = None


def run(*args, **kwargs):
    return subprocess.check_output(args, text=True, **kwargs).strip()


def await_stage(stage, timeout=40):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        result = ARTIFACTS / "result.json"
        if result.exists():
            value = json.loads(result.read_text())
            assert value["ok"], value.get("error")
        path = ARTIFACTS / "state.json"
        if path.exists():
            value = json.loads(path.read_text())
            if value["stage"] == stage:
                assert not value["errors"], value["errors"]
                assert not value.get("pixel_error"), value.get("pixel_error")
                assert value["channel_mode"] == "bytes"
                assert value["buffer_type"] == "terminal"
                return value
        time.sleep(0.1)
    raise AssertionError(f"timed out waiting for {stage}; artifacts {ARTIFACTS}")


def action(value):
    (ARTIFACTS / "action").write_text(value)


def screenshot(name):
    # Kitty 直接捕获目标窗口帧缓冲，避免把用户切换窗口/工作区误判为图片闪烁。
    path = ARTIFACTS / (name + ".png")
    run("kitten", "@", "screenshot", "--match", "id:" + window_id, str(path))
    return path


def await_page_color(name, predicate, timeout=20):
    # The engine creates a placement before Chromium publishes the page frame.
    # Wait for actual rendered page pixels, not that earlier transport event.
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        path = screenshot(name)
        color = [
            float(v)
            for v in run(
                "magick",
                str(path),
                "-format",
                "%[fx:p{20,200}.r],%[fx:p{20,200}.g],%[fx:p{20,200}.b]",
                "info:",
            ).split(",")
        ]
        if predicate(color):
            return path
        time.sleep(0.15)
    raise AssertionError(
        ("page pixels did not reach expected state", name, color, ARTIFACTS)
    )


try:
    window_id = run(
        "kitten",
        "@",
        "launch",
        "--type=os-window",
        "--keep-focus",
        "--cwd=" + str(ROOT),
        "--os-window-class=" + CLASS,
        "--title=Lua-owned terminal acceptance",
        "--env=KITTY_LUA_TEST_DIR=" + str(ARTIFACTS),
        "nvim",
        "-u",
        "NONE",
        "-c",
        'autocmd VimEnter * ++once lua vim.defer_fn(function() dofile("tests/unit/kitty_terminal_host.lua") end, 300)',
    )
    initial = await_stage("icat")
    assert initial["pixel_source"] == "ioctl", initial["pixel_source"]
    image = screenshot("icat")
    colors = int(run("magick", str(image), "-format", "%k", "info:"))
    assert colors > 1000, ("requested wallpaper was not visibly rendered", colors)
    action("resize")
    resized = await_stage("resized")
    assert resized["cells"][0] < initial["cells"][0]
    screenshot("resized")
    action("hide")
    hidden = await_stage("hidden")
    assert not hidden["views"], hidden["views"]
    hidden_image = screenshot("hidden")
    assert int(run("magick", str(hidden_image), "-format", "%k", "info:")) < 1000, (
        "hidden image remained on host"
    )
    action("restore")
    await_stage("restored")
    restored_image = screenshot("restored")
    assert int(run("magick", str(restored_image), "-format", "%k", "info:")) > 1000, (
        "restored image missing"
    )
    action("input")
    await_stage("input_ready")
    run("kitten", "@", "send-text", "--match=id:" + window_id, "actual-pty-input\r")
    await_stage("input")
    run("kitten", "@", "send-text", "--match=id:" + window_id, "\x1c\x0e")
    action("scrollback")
    scrollback = await_stage("scrollback")
    assert scrollback["capture"] is False
    scrollback_image = screenshot("scrollback")
    assert int(run("magick", str(scrollback_image), "-format", "%k", "info:")) > 1000, (
        "scrollback lost image anchor"
    )
    action("browser")
    browser = await_stage("browser", 55)
    assert browser["stats"].get("local_graphics_queries", 0) >= 1
    before = await_page_color(
        "browser",
        lambda c: 0.12 < c[0] < 0.17 and 0.32 < c[1] < 0.38 and 0.6 < c[2] < 0.66,
    )
    # Observe a continuously animating page across distinct compositor frames.
    # Static blue pixels must never expose the Nvim background while its square
    # changes color; unlike a single final screenshot this catches blank frames.
    animation_samples = []
    for index in range(30):
        frame = screenshot("animation-%02d" % index)
        values = [
            float(v)
            for v in run(
                "magick",
                str(frame),
                "-format",
                "%[fx:p{20,200}.r],%[fx:p{20,200}.g],%[fx:p{20,200}.b],%[fx:p{200,200}.r],%[fx:p{200,200}.b]",
                "info:",
            ).split(",")
        ]
        assert (
            0.12 < values[0] < 0.17
            and 0.32 < values[1] < 0.38
            and 0.6 < values[2] < 0.66
        ), ("blank browser animation frame", index, values)
        animation_samples.append(values)
        time.sleep(0.035)
    assert (
        max(v[3] for v in animation_samples) - min(v[3] for v in animation_samples)
        > 0.2
    ), "test page animation did not update"
    (ARTIFACTS / "animation-samples.json").write_text(json.dumps(animation_samples))
    action("type")
    ready = await_stage("browser_input_ready")
    view = ready["views"][0]
    # The browser application focuses its web surface on click; DOM autofocus
    # alone doesn't transfer terminal-browser's own address-bar focus.
    mx, my = view["col"] + 4, view["row"] + 5
    run(
        "kitten",
        "@",
        "send-text",
        "--match=id:" + window_id,
        f"\x1b[<0;{mx};{my}M\x1b[<0;{mx};{my}m",
    )
    time.sleep(0.15)
    run("kitten", "@", "send-text", "--match=id:" + window_id, "hello-lua")
    typed = await_stage("typed")
    assert typed["host_graphics"]["uploads"] > 5, typed["host_graphics"]
    assert typed["host_graphics"]["deletes"] == 0, (
        "animation still removes host placements",
        typed["host_graphics"],
    )
    assert typed["mode"] == "t" and typed["capture"] is True
    assert (
        typed["view_channel"]["mode"] == "terminal"
        and typed["view_channel"]["internal"] is True
    )
    assert typed["stats"].get("native_input_calls", 0) > 0, (
        "input bypassed native on_input"
    )
    after = await_page_color(
        "typed", lambda c: c[0] < 0.05 and c[1] > 0.6 and 0.25 < c[2] < 0.4
    )
    color = [
        float(v)
        for v in run(
            "magick",
            str(after),
            "-format",
            "%[fx:p{20,200}.r],%[fx:p{20,200}.g],%[fx:p{20,200}.b]",
            "info:",
        ).split(",")
    ]
    assert color[0] < 0.05 and color[1] > 0.6 and 0.25 < color[2] < 0.4, (
        "page input did not receive exact hello-lua (expected green JS acknowledgment)",
        color,
        typed.get("keyboard_flags"),
        typed["stats"],
    )
    difference = float(
        run(
            "magick",
            str(before),
            str(after),
            "-compose",
            "difference",
            "-composite",
            "-format",
            "%[fx:mean]",
            "info:",
        )
    )
    assert difference > 0.000001, (
        "browser input did not change rendered pixels",
        difference,
    )
    action("shell")
    await_stage("shell_ready")
    action("paste_shell")
    await_stage("shell_pasted")
    run("kitten", "@", "send-text", "--match=id:" + window_id, "\r")
    await_stage("shell")
    action("palette")
    await_stage("palette")
    palette = screenshot("palette")
    color = [
        float(v)
        for v in run(
            "magick",
            str(palette),
            "-format",
            "%[fx:p{20,10}.r],%[fx:p{20,10}.g],%[fx:p{20,10}.b]",
            "info:",
        ).split(",")
    ]
    assert all(
        abs(a - b) < 0.02 for a, b in zip(color, [18 / 255, 171 / 255, 52 / 255])
    ), ("native OSC4 palette color mismatch", color)
    action("exit_shell")
    run("kitten", "@", "send-text", "--match=id:" + window_id, "exit\r")
    deadline = time.monotonic() + 10
    while not (ARTIFACTS / "result.json").exists() and time.monotonic() < deadline:
        time.sleep(0.1)
    result = json.loads((ARTIFACTS / "result.json").read_text())
    assert result["ok"], result.get("error")
    print(
        "PASS: icat image pixels; pane resize/hide/scroll; real mouse/keys and browser DOM acknowledgment; default shell command and clean exit"
    )
    print("Artifacts:", ARTIFACTS)
except BaseException:
    print("Artifacts:", ARTIFACTS)
    if window_id:
        subprocess.run(
            ["kitten", "@", "close-window", "--match=id:" + window_id],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    raise
