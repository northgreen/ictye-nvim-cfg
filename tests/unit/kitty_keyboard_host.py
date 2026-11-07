#!/usr/bin/env python3
"""真实 Kitty 编码和隐藏输入通道验收：多键事件、退出终端模式、失焦及清理。
由 Kitty 自身编码事件并注入本测试的隐藏窗口，不抢用户焦点、不联网。
"""

import json
import re
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ARTIFACTS = Path(tempfile.mkdtemp(prefix="kitty-keyboard-host-"))
print("Artifacts:", ARTIFACTS, flush=True)

RECORDER = r"""
import json,os,sys,time,tty
from pathlib import Path
tty.setraw(0)
os.write(1,b'\x1b[>11u\x1b[?u')
events=[]
while True:
    data=os.read(0,4096)
    if not data: break
    events.append({'time':time.monotonic(),'hex':data.hex()})
    path=Path(sys.argv[1])
    path.with_suffix('.tmp').write_text(json.dumps(events))
    path.with_suffix('.tmp').replace(path)
"""

DRIVER = r"""
vim.opt.rtp:prepend(vim.env.KEYBOARD_TEST_ROOT)
local dir = vim.env.KEYBOARD_TEST_DIR
vim.defer_fn(function()
    require('global.ui_util.ui.float_term')(
        vim.json.decode(table.concat(vim.fn.readfile(dir..'/command.json'),'\n')),
        {width=60,height=12})
    local term = require('experimental.kitty_terminal').current()
    local win = vim.api.nvim_get_current_win()
    local first, first_win = term, win
    -- 桌面仍由用户操作；关闭此测试窗口的外部焦点通知，后续显式触发边界事件。
    vim.api.nvim_ui_send('\27[?1004l')
    local function tick()
        local action = dir..'/action'
        if vim.fn.filereadable(action)==1 then
            local value = vim.fn.readfile(action)[1]
            vim.fn.delete(action)
            if value=='enter' then term:enter()
            elseif value=='close' then vim.api.nvim_win_close(win,true)
            elseif value=='second' then
                local command=vim.json.decode(table.concat(vim.fn.readfile(dir..'/command.json'),'\n'))
                command[#command]=dir..'/events2.json'
                require('global.ui_util.ui.float_term')(command,{width=60,height=12})
                term=require('experimental.kitty_terminal').current()
                win=vim.api.nvim_get_current_win()
            elseif value=='first' then
                vim.api.nvim_win_close(win,true)
                term,win=first,first_win
                vim.api.nvim_set_current_win(win)
                term:enter()
            elseif value=='focusout' then vim.api.nvim_exec_autocmds('FocusLost',{})
            elseif value=='focusin' then vim.api.nvim_exec_autocmds('FocusGained',{}) end
        end
        local raw=term.host_input or {}
        local state={mode=vim.api.nvim_get_mode().mode,captured=raw.captured or false,
            ready=raw.ready or false,flags=term.keyboard_flags,error=term.keyboard_error,
            errors=term.errors,closed=term.closed or false,overlay=raw.overlay,path=raw.path}
        vim.fn.writefile({vim.json.encode(state)},dir..'/state.tmp')
        vim.uv.fs_rename(dir..'/state.tmp',dir..'/state.json')
        vim.defer_fn(tick,50)
    end
    tick()
end,300)
"""


KEY_SENDER = r"""
from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, EventType

def main(args):
    raise SystemExit('test-only no_ui kitten')

@result_handler(no_ui=True)
def handle_result(args,data,target_window_id,boss):
    parent=boss.window_id_map[target_window_id]
    overlay=getattr(parent,'_kitty_terminal_bridge_capture_id',0)
    if not overlay: raise RuntimeError('test input bridge must be capturing')
    mods=int(args[3])
    event=KeyEvent(key=args[1],mods=mods,ctrl=bool(mods&4),shift=bool(mods&1),type=getattr(EventType,args[2]))
    boss.window_id_map[overlay].send_key_sequence(event.as_window_system_event(),synthesize_release_events=False)
    return 'sent'
"""


def run(*args):
    return subprocess.check_output(args, text=True).strip()


def windows():
    return [
        w
        for osw in json.loads(run("kitten", "@", "ls"))
        for tab in osw["tabs"]
        for w in tab["windows"]
    ]


def state():
    path = ARTIFACTS / "state.json"
    return json.loads(path.read_text()) if path.exists() else {}


def wait_for(predicate, message, timeout=8):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        current = state()
        assert not current.get("error"), current
        assert not current.get("errors"), current
        if predicate(current):
            return current
        time.sleep(0.05)
    raise AssertionError((message, state(), ARTIFACTS))


def events():
    path = ARTIFACTS / "events.json"
    return json.loads(path.read_text()) if path.exists() else []


parent = other = None
try:
    (ARTIFACTS / "driver.lua").write_text(DRIVER)
    (ARTIFACTS / "key_sender.py").write_text(KEY_SENDER)
    (ARTIFACTS / "command.json").write_text(
        json.dumps(["python3", "-c", RECORDER, str(ARTIFACTS / "events.json")])
    )
    parent = run(
        "kitten",
        "@",
        "launch",
        "--type=os-window",
        "--title=Kitty keyboard regression",
        "--keep-focus",
        "--cwd=" + str(ROOT),
        "--env=KEYBOARD_TEST_ROOT=" + str(ROOT),
        "--env=KEYBOARD_TEST_DIR=" + str(ARTIFACTS),
        "nvim",
        "-u",
        "NONE",
        "-c",
        'lua dofile("' + str(ARTIFACTS / "driver.lua") + '")',
    )
    initial = wait_for(
        lambda s: s.get("flags") == 11 and s.get("captured"), "bridge readiness"
    )

    def send(key, action, mods=0):
        run(
            "kitten",
            "@",
            "kitten",
            "--match",
            "id:" + parent,
            str(ARTIFACTS / "key_sender.py"),
            key,
            action,
            str(mods),
        )

    for key in ("UP", "z", "LEFT_SHIFT"):
        send(key, "PRESS")
    time.sleep(0.8)
    for key in ("LEFT_SHIFT", "z", "UP"):
        send(key, "RELEASE")
    wait_for(
        lambda s: all(
            packet in b"".join(bytes.fromhex(e["hex"]) for e in events())
            for packet in (b"\x1b[1;1:3A", b"\x1b[122;1:3u", b"\x1b[57441;1:3u")
        ),
        "all recorded release events",
    )
    observed = []
    for chunk in events():
        for match in re.finditer(
            rb"\x1b\[(\d*)(?:;([\d:]*))?([uABCD])", bytes.fromhex(chunk["hex"])
        ):
            code, mods, final = match.groups()
            fields = (mods or b"1").split(b":")
            event = int(fields[1]) if len(fields) > 1 else 1
            key = "Up" if final == b"A" else int(code)
            observed.append((key, event, chunk["time"]))
    for key in ("Up", 122, 57441):
        down = next(t for k, e, t in observed if k == key and e == 1)
        up = next(t for k, e, t in observed if k == key and e == 3)
        assert up - down >= 0.6, (key, observed)
    send("\\", "PRESS", 4)
    send("\\", "RELEASE", 4)
    send("n", "PRESS", 4)
    wait_for(
        lambda s: s.get("mode", "").startswith("n") and not s.get("captured"),
        "Ctrl-\\ Ctrl-N releases capture",
    )
    (ARTIFACTS / "action").write_text("enter")
    wait_for(
        lambda s: s.get("mode") == "t" and s.get("captured"), "return to Terminal-mode"
    )
    (ARTIFACTS / "action").write_text("second")
    second = wait_for(
        lambda s: (
            s.get("overlay") != initial["overlay"]
            and s.get("captured")
            and s.get("flags") == 11
        ),
        "second session captures without rejecting parent ownership",
    )
    send("x", "PRESS")
    send("x", "RELEASE")
    (ARTIFACTS / "action").write_text("first")
    wait_for(
        lambda s: s.get("overlay") == initial["overlay"] and s.get("captured"),
        "returning first session restores its own helper",
    )
    deadline = time.monotonic() + 5
    while any(str(w["id"]) == second["overlay"] for w in windows()):
        assert time.monotonic() < deadline, "second session helper leaked"
        time.sleep(0.1)
    other = run(
        "kitten",
        "@",
        "launch",
        "--type=os-window",
        "--title=Keyboard isolation target",
        "--keep-focus",
        "python3",
        "-c",
        "import time; time.sleep(30)",
    )
    (ARTIFACTS / "action").write_text("focusout")
    wait_for(lambda s: not s.get("captured"), "focus loss disables capture")
    before = events()
    run("kitten", "@", "send-key", "--match", "id:" + other, "z")
    time.sleep(0.15)
    assert events() == before, "other Kitty window leaked keyboard input"
    (ARTIFACTS / "action").write_text("focusin")
    wait_for(lambda s: s.get("captured"), "focus return restores capture")
    (ARTIFACTS / "action").write_text("close")
    wait_for(lambda s: s.get("closed"), "closing float closes raw session")
    deadline = time.monotonic() + 5
    while any(str(w["id"]) == initial["overlay"] for w in windows()):
        assert time.monotonic() < deadline, "hidden keyboard helper leaked"
        time.sleep(0.1)
    assert not Path(initial["path"]).exists(), "input socket leaked"
    result = {"ok": True, "observed": observed, "cleanup": state()}
    (ARTIFACTS / "result.json").write_text(json.dumps(result, indent=2))
    print(
        "PASS: Kitty press/release, mode escape, two sessions, focus events and cleanup"
    )
    print("Artifacts:", ARTIFACTS)
finally:
    for window in (other, parent):
        if window:
            subprocess.run(
                ["kitten", "@", "close-window", "--match", "id:" + window], check=False
            )
