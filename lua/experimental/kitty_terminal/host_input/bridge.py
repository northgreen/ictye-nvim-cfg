import os
import select
import socket
import sys
import termios
import time
import tty


def main(args):
    raise SystemExit("This is a no_ui Kitty input bridge")


def connect_reader(socket_path):
    connection = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    deadline = time.monotonic() + 2
    try:
        while True:
            connection.settimeout(max(0.001, deadline - time.monotonic()))
            try:
                connection.connect(socket_path)
                return connection
            except (FileNotFoundError, ConnectionRefusedError):
                if time.monotonic() >= deadline:
                    raise
                time.sleep(0.02)
    except BaseException:
        connection.close()
        raise


def apply_controls(buffered, data):
    lines = (buffered + data).split(b"\n")
    buffered = lines.pop()
    if len(buffered) > 32:
        raise ValueError("keyboard control line exceeds 32 bytes")
    for line in lines:
        if len(line) > 32 or not line.isdigit() or int(line) > 27:
            raise ValueError("keyboard flags must be ASCII digits in 0..27")
        os.write(1, f"\x1b[={int(line) & 27}u".encode("ascii"))
    return buffered


def relay_input(connection):
    connection.setblocking(False)
    pending = bytearray(b"\0")
    controls = b""
    while True:
        readable, writable, _ = select.select(
            [connection] if pending else [connection, 0],
            [connection] if pending else [],
            [],
        )
        # 优先处理编辑器断开，避免继续读取终端。
        if connection in readable:
            data = connection.recv(4096)
            if not data:
                return
            controls = apply_controls(controls, data)
        if connection in writable:
            try:
                del pending[: connection.send(pending)]
            except BlockingIOError:
                pass
        if 0 in readable:
            data = os.read(0, 65536)
            if not data:
                return
            pending.extend(data)


def read_keyboard(socket_path):
    import signal

    def exit_on_signal(signum, frame):
        raise SystemExit(0)

    with connect_reader(socket_path) as connection:
        original_attributes = termios.tcgetattr(0)
        signal.signal(signal.SIGHUP, exit_on_signal)
        signal.signal(signal.SIGTERM, exit_on_signal)
        try:
            tty.setraw(0)
            os.write(1, b"\x1b[>27u")
            relay_input(connection)
        finally:
            try:
                os.write(1, b"\x1b[<u")
            finally:
                termios.tcsetattr(0, termios.TCSANOW, original_attributes)


def start_bridge(parent, tab, boss, helper_path, socket_path):
    from kitty.fast_data_types import (
        buffer_keys_in_window,
        set_redirect_keys_to_overlay,
    )

    if not os.path.isabs(helper_path) or not os.path.isfile(helper_path):
        raise ValueError("bridge helper must be an existing absolute file path")
    if not os.path.isabs(socket_path):
        raise ValueError("bridge socket must be an absolute path")
    owned_ids = getattr(parent, "_kitty_terminal_bridge_overlay_ids", set())
    capture_id = getattr(parent, "_kitty_terminal_bridge_capture_id", 0)
    overlay = tab.new_window(
        use_shell=False,
        cmd=["python3", helper_path, "--reader", socket_path],
        overlay_for=parent.id,
        overlay_behind=True,
    )
    try:
        # Kitty 创建隐藏覆盖层时会自动重定向；返回前立即撤销。
        source_id = overlay.keys_redirected_till_ready_from or parent.id
        set_redirect_keys_to_overlay(parent.os_window_id, tab.id, source_id, capture_id)
        buffer_keys_in_window(parent.os_window_id, tab.id, overlay.id, False)
        overlay.keys_redirected_till_ready_from = 0
        owned_ids.add(overlay.id)
        parent._kitty_terminal_bridge_overlay_ids = owned_ids
        parent._kitty_terminal_bridge_capture_id = capture_id
    except BaseException:
        boss.mark_window_for_close(overlay)
        raise
    return str(overlay.id)


def control_bridge(parent, tab, boss, command, overlay_id, capture=False):
    from kitty.fast_data_types import set_redirect_keys_to_overlay

    owned_ids = getattr(parent, "_kitty_terminal_bridge_overlay_ids", set())
    if overlay_id <= 0 or overlay_id not in owned_ids:
        raise ValueError("overlay is not owned by this parent")
    overlay = boss.window_id_map.get(overlay_id)
    if overlay is not None and overlay.tabref() is not tab:
        raise ValueError("bridge overlay is no longer in its parent's tab")
    if command == "capture" and overlay is None:
        raise ValueError("bridge overlay has already exited")
    if capture or getattr(parent, "_kitty_terminal_bridge_capture_id", 0) == overlay_id:
        set_redirect_keys_to_overlay(
            parent.os_window_id, tab.id, parent.id, overlay_id if capture else 0
        )
        parent._kitty_terminal_bridge_capture_id = overlay_id if capture else 0
    if command == "stop":
        owned_ids.remove(overlay_id)
        if overlay is not None:
            boss.mark_window_for_close(overlay)
        return "stopped"
    return "1" if capture else "0"


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] != "--reader":
        sys.exit(1)
    try:
        read_keyboard(sys.argv[2])
    except (OSError, termios.error, ValueError):
        sys.exit(1)
else:
    from kittens.tui.handler import result_handler

    @result_handler(no_ui=True)
    def handle_result(args, data, target_window_id, boss):
        parent = boss.window_id_map.get(target_window_id)
        if parent is None or (tab := parent.tabref()) is None:
            raise ValueError("bridge parent window is no longer available")
        command = args[1] if len(args) > 1 else ""
        if command == "start" and len(args) == 4:
            return start_bridge(parent, tab, boss, args[2], args[3])
        if command == "stop" and len(args) == 3:
            return control_bridge(parent, tab, boss, command, int(args[2]))
        if command == "capture" and len(args) == 4 and args[3] in ("0", "1"):
            return control_bridge(
                parent, tab, boss, command, int(args[2]), args[3] == "1"
            )
        raise ValueError(
            "expected start HELPER SOCKET, capture OVERLAY_ID 1|0, or stop OVERLAY_ID"
        )
