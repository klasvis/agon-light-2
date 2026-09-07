#!/usr/bin/env python3
"""
Agon Light - Live VDP Screen & Tektronix 4014 Graphics Monitor
Receives vector & graphics stream from Agon Light via Serial (COM4) or Wi-Fi TCP,
and renders in full color on a high-resolution virtual monitor with complete support
for BBC BASIC graphics (filled rectangles, circles, triangles, ellipses, bitmaps)
as well as authentic Tektronix 4014 storage tube vector files (.plt).
"""

import sys
import time
import socket
import threading
import pygame

# Virtual monitor internal resolution: 1024 x 780 (4:3 aspect ratio)
TEK_W = 1024
TEK_H = 780

# P31 Phosphor Green Palette (default for vintage Tektronix mode)
COLOR_BG     = (10, 20, 12)       # Deep dark storage tube phosphor background
COLOR_VECTOR = (60, 255, 100)     # Glowing P31 phosphor green vectors
COLOR_TEXT   = (50, 230, 90)      # Phosphor green alphanumeric characters

def safe_color(c, default=(0, 0, 0)):
    """Guarantees a valid (R, G, B) tuple of ints in range 0..255 for Pygame."""
    try:
        if isinstance(c, (list, tuple)) and len(c) >= 3:
            return (
                max(0, min(255, int(c[0]))),
                max(0, min(255, int(c[1]))),
                max(0, min(255, int(c[2])))
            )
    except Exception:
        pass
    return default

def clamp_int(val, default=0, min_v=0, max_v=255):
    """Safely converts val to an integer clamped between min_v and max_v."""
    try:
        return max(min_v, min(max_v, int(val)))
    except Exception:
        return default

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Agon Light Live VDP Screen & Tektronix Monitor")
    parser.add_argument("--port", default="COM4", help="Serial port (default: COM4)")
    parser.add_argument("--baud", type=int, default=115200, help="Baud rate (default: 115200, use 921600 or press F9 to toggle)")
    parser.add_argument("--wifi", default=None, help="Connect via Wi-Fi TCP (e.g. 192.168.1.50:23)")
    parser.add_argument("--file", default=None, help="Preview a local .plt file directly")
    args = parser.parse_args()

    sock = None
    ser = None
    is_wifi = False
    local_data = [None]
    current_baud = [args.baud]

    if args.file:
        try:
            with open(args.file, "rb") as f:
                local_data[0] = f.read()
            print(f"[VDP Monitor] Previewing file: {args.file} ({len(local_data[0]):,} bytes)")
        except Exception as e:
            print(f"[VDP Monitor] Could not read file {args.file}: {e}")
            sys.exit(1)
    elif args.wifi:
        host, port_str = args.wifi.split(":")
        port = int(port_str)
        print(f"[VDP Monitor] Connecting to Agon via Wi-Fi {host}:{port}...")
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5.0)
            sock.connect((host, port))
            sock.settimeout(0.01)
            is_wifi = True
            print(f"[VDP Monitor] Connected to Agon at {host}:{port}!")
        except Exception as e:
            print(f"[VDP Monitor] Wi-Fi connection error: {e}")
            sys.exit(1)
    else:
        import serial
        print(f"[VDP Monitor] Opening serial port {args.port} at {current_baud[0]} baud...")
        print(f"[VDP Monitor] Tip: Press F9 inside the monitor window to toggle between 115200 and 921600 baud!")
        try:
            ser = serial.Serial(args.port, current_baud[0], timeout=0.01)
            print(f"[VDP Monitor] Connected to {args.port}!")
        except Exception as e:
            print(f"[VDP Monitor] Could not open serial port {args.port}: {e}")
            sys.exit(1)

    # Initialize Pygame
    pygame.init()
    pygame.font.init()

    win_w = 1024
    win_h = 780
    window = pygame.display.set_mode((win_w, win_h), pygame.RESIZABLE)
    title = f"Agon Light 2 - Live VDP Screen Monitor [{'Wi-Fi' if is_wifi else f'{args.port} @ {current_baud[0]} baud (F9: toggle)'}]"
    pygame.display.set_caption(title)

    canvas = pygame.Surface((TEK_W, TEK_H))
    canvas.fill(COLOR_BG)
    canvas_lock = threading.Lock()

    # Dynamic metrics based on screen mode
    cursor_metrics = {
        "cols": 80,
        "rows": 30,
        "char_w": TEK_W / 80,
        "char_h": TEK_H / 30,
        "font": pygame.font.SysFont("Consolas", 18)
    }

    cursor = {"col": 0, "row": 0}
    running = [True]

    # Live VDP Colors (RGB888)
    cur_text_fg = [255, 255, 255]
    cur_text_bg = [0, 0, 0]
    cur_gfx_fg  = [255, 255, 255]
    cur_gfx_bg  = [0, 0, 0]

    # Stored bitmaps (id -> pygame.Surface)
    bitmaps = {}

    # Extended command state
    in_ext_cmd = [False]
    ext_buf = bytearray()

    # Tektronix 4010/4014 state machine
    tek = {
        "mode": 0,          # 0 = Alpha, 1..4 = Dark move, 5..8 = Bright draw, 30 = Esc
        "savemode": 0,
        "xh": 0, "xl": 0, "yh": 0, "yl": 0, "xy4014": 0,
        "x0": 0, "y0": 0,
        "x2": 0, "y2": 0
    }

    def erase_screen(bg_col=None):
        col = safe_color(bg_col if bg_col is not None else cur_text_bg)
        canvas.fill(col)
        cursor["col"] = 0
        cursor["row"] = 0
        tek["x0"] = 0
        tek["y0"] = 0

    def handle_ext_cmd(cmd_bytes):
        try:
            cmd_str = cmd_bytes.decode("latin1", errors="ignore").strip()
        except Exception:
            return
        if not cmd_str:
            return
        parts = cmd_str.split()
        if not parts:
            return
        op = parts[0]
        try:
            if op == "C" and len(parts) >= 4:
                cur_gfx_fg[0] = clamp_int(parts[1], 255)
                cur_gfx_fg[1] = clamp_int(parts[2], 255)
                cur_gfx_fg[2] = clamp_int(parts[3], 255)
            elif op == "BC" and len(parts) >= 4:
                cur_gfx_bg[0] = clamp_int(parts[1], 0)
                cur_gfx_bg[1] = clamp_int(parts[2], 0)
                cur_gfx_bg[2] = clamp_int(parts[3], 0)
            elif op == "K" and len(parts) >= 4:
                cur_text_fg[0] = clamp_int(parts[1], 255)
                cur_text_fg[1] = clamp_int(parts[2], 255)
                cur_text_fg[2] = clamp_int(parts[3], 255)
            elif op == "B" and len(parts) >= 4:
                cur_text_bg[0] = clamp_int(parts[1], 0)
                cur_text_bg[1] = clamp_int(parts[2], 0)
                cur_text_bg[2] = clamp_int(parts[3], 0)
            elif op == "J" and len(parts) >= 3:
                cursor["col"] = max(0, min(cursor_metrics.get("cols", 80) - 1, int(parts[1])))
                cursor["row"] = max(0, min(cursor_metrics.get("rows", 30) - 1, int(parts[2])))
            elif op == "X":
                erase_screen()
            elif op == "M" and len(parts) >= 6:
                m_cols = int(parts[4])
                m_rows = int(parts[5])
                if m_cols > 0 and m_rows > 0:
                    cursor_metrics["cols"] = m_cols
                    cursor_metrics["rows"] = m_rows
                    cursor_metrics["char_w"] = TEK_W / m_cols
                    cursor_metrics["char_h"] = TEK_H / m_rows
                    font_size = max(10, int(cursor_metrics["char_h"] * 0.85))
                    cursor_metrics["font"] = pygame.font.SysFont("Consolas", font_size)
            elif op == "CLS":
                if len(parts) >= 4:
                    cur_text_bg[0] = clamp_int(parts[1], 0)
                    cur_text_bg[1] = clamp_int(parts[2], 0)
                    cur_text_bg[2] = clamp_int(parts[3], 0)
                erase_screen(safe_color(cur_text_bg))
            elif op == "CLG":
                if len(parts) >= 4:
                    cur_gfx_bg[0] = clamp_int(parts[1], 0)
                    cur_gfx_bg[1] = clamp_int(parts[2], 0)
                    cur_gfx_bg[2] = clamp_int(parts[3], 0)
                canvas.fill(safe_color(cur_gfx_bg))
            elif op == "L" and len(parts) >= 5:
                x1, y1, x2, y2 = int(parts[1]), int(parts[2]), int(parts[3]), int(parts[4])
                pygame.draw.aaline(canvas, safe_color(cur_gfx_fg), (x1, y1), (x2, y2))
            elif op == "P" and len(parts) >= 3:
                x, y = int(parts[1]), int(parts[2])
                if 0 <= x < TEK_W and 0 <= y < TEK_H:
                    canvas.set_at((x, y), safe_color(cur_gfx_fg))
            elif op == "R" and len(parts) >= 6:
                x1, y1, x2, y2 = int(parts[1]), int(parts[2]), int(parts[3]), int(parts[4])
                filled = (int(parts[5]) != 0)
                rx = min(x1, x2)
                ry = min(y1, y2)
                rw = max(1, abs(x2 - x1) + 1)
                rh = max(1, abs(y2 - y1) + 1)
                pygame.draw.rect(canvas, safe_color(cur_gfx_fg), (rx, ry, rw, rh), 0 if filled else 1)
            elif op == "CI" and len(parts) >= 5:
                cx, cy, r = int(parts[1]), int(parts[2]), int(parts[3])
                filled = (int(parts[4]) != 0)
                if r > 0:
                    pygame.draw.circle(canvas, safe_color(cur_gfx_fg), (cx, cy), r, 0 if filled else 1)
            elif op == "T" and len(parts) >= 8:
                x1, y1, x2, y2, x3, y3 = [int(p) for p in parts[1:7]]
                filled = (int(parts[7]) != 0)
                pygame.draw.polygon(canvas, safe_color(cur_gfx_fg), [(x1, y1), (x2, y2), (x3, y3)], 0 if filled else 1)
            elif op == "Q" and len(parts) >= 10:
                x1, y1, x2, y2, x3, y3, x4, y4 = [int(p) for p in parts[1:9]]
                filled = (int(parts[9]) != 0)
                pygame.draw.polygon(canvas, safe_color(cur_gfx_fg), [(x1, y1), (x2, y2), (x3, y3), (x4, y4)], 0 if filled else 1)
            elif op == "E" and len(parts) >= 6:
                cx, cy, rx, ry = int(parts[1]), int(parts[2]), int(parts[3]), int(parts[4])
                filled = (int(parts[5]) != 0)
                if rx > 0 and ry > 0:
                    rect = pygame.Rect(cx - rx, cy - ry, 2 * rx, 2 * ry)
                    pygame.draw.ellipse(canvas, safe_color(cur_gfx_fg), rect, 0 if filled else 1)
            elif op == "BM" and len(parts) >= 6:
                b_id = int(parts[1])
                b_fmt = int(parts[2])
                bw = int(parts[3])
                bh = int(parts[4])
                raw = bytes.fromhex(parts[5])
                if b_fmt == 0 and len(raw) >= bw * bh * 4: # RGBA8888
                    bmp_surf = pygame.image.frombuffer(raw[:bw * bh * 4], (bw, bh), "RGBA")
                    bitmaps[b_id] = bmp_surf
                elif b_fmt == 1 and len(raw) >= bw * bh: # RGBA2222 (used by Cybernoid & Agon games)
                    lut = bytes([0, 85, 170, 255])
                    rgba32 = bytearray(bw * bh * 4)
                    pos = 0
                    for b in raw[:bw * bh]:
                        rgba32[pos]   = lut[b & 3]          # R (bits 0-1)
                        rgba32[pos+1] = lut[(b >> 2) & 3]   # G (bits 2-3)
                        rgba32[pos+2] = lut[(b >> 4) & 3]   # B (bits 4-5)
                        rgba32[pos+3] = lut[(b >> 6) & 3]   # A (bits 6-7)
                        pos += 4
                    bmp_surf = pygame.image.frombuffer(rgba32, (bw, bh), "RGBA")
                    bitmaps[b_id] = bmp_surf
            elif op == "BD" and len(parts) >= 4:
                b_id = int(parts[1])
                bx = int(parts[2])
                by = int(parts[3])
                bw = int(parts[4]) if len(parts) > 4 else None
                bh = int(parts[5]) if len(parts) > 5 else None
                if b_id in bitmaps:
                    surf = bitmaps[b_id]
                    if bw and bh and (bw != surf.get_width() or bh != surf.get_height()):
                        scaled_bmp = pygame.transform.scale(surf, (max(1, bw), max(1, bh)))
                        canvas.blit(scaled_bmp, (bx, by))
                    else:
                        canvas.blit(surf, (bx, by))
        except Exception:
            pass

    def stream_read():
        if local_data[0] is not None:
            if local_data[0]:
                chunk = local_data[0][:256]
                local_data[0] = local_data[0][256:]
                time.sleep(0.005)
                return chunk
            else:
                time.sleep(0.05)
                return b""
        elif is_wifi:
            try:
                return sock.recv(1024)
            except (socket.timeout, BlockingIOError):
                return b""
            except Exception:
                return b""
        else:
            try:
                if ser and ser.is_open:
                    n = ser.in_waiting
                    return ser.read(max(1, min(n, 16384)))
            except Exception:
                time.sleep(0.02)
            return b""

    def stream_write(data):
        if is_wifi:
            try:
                sock.sendall(data)
            except Exception as e:
                print(f"Wi-Fi send error: {e}")
        else:
            try:
                if ser and ser.is_open:
                    ser.write(data)
            except Exception as e:
                print(f"Serial send error: {e}")

    def serial_reader():
        while running[0]:
            try:
                chunk = stream_read()
                if chunk is None:
                    break
                if not chunk:
                    continue

                with canvas_lock:
                    for b in chunk:
                        try:
                            # Extended command stream handling (\x1E ... \n)
                            if in_ext_cmd[0]:
                                if b == 10 or b == 13: # End of extended command
                                    in_ext_cmd[0] = False
                                    handle_ext_cmd(ext_buf)
                                    ext_buf.clear()
                                elif b == 0x1E: # New extended command started
                                    handle_ext_cmd(ext_buf)
                                    ext_buf.clear()
                                else:
                                    if len(ext_buf) < 300000:
                                        ext_buf.append(b)
                                continue

                            if b == 0x1E:
                                in_ext_cmd[0] = True
                                ext_buf.clear()
                                continue

                            # Return to alpha check for Tektronix mode
                            if tek["mode"] != 0:
                                if b == 27:
                                    tek["savemode"] = tek["mode"]
                                if b == 31 or b == 13 or b == 27:
                                    tek["mode"] = 30 if b == 27 else 0
                                    continue

                            # Escape sequence handling
                            if tek["mode"] == 30:
                                tek["mode"] = tek["savemode"]
                                if b == 0x0C:  # ESC FF: Erase Page
                                    erase_screen()
                                continue

                            # Control characters
                            if b == 7:     # BEL
                                continue
                            elif b == 12:  # FF: Erase Page
                                erase_screen()
                                continue
                            elif b == 13:  # CR
                                tek["mode"] = 0
                                cursor["col"] = 0
                                continue
                            elif b == 10:  # LF
                                ch = cursor_metrics["char_h"]
                                c_rows = cursor_metrics["rows"]
                                cursor["row"] += 1
                                if cursor["row"] >= c_rows:
                                    canvas.scroll(0, -int(ch))
                                    pygame.draw.rect(canvas, safe_color(cur_text_bg), (0, TEK_H - int(ch), TEK_W, int(ch)))
                                    cursor["row"] = c_rows - 1
                                continue
                            elif b == 27:  # ESC
                                tek["savemode"] = tek["mode"]
                                tek["mode"] = 30
                                continue
                            elif b == 29:  # GS: Enter Vector Mode (mode 1 = move)
                                tek["mode"] = 1
                                continue
                            elif b == 31:  # US: Return to Alpha Mode
                                tek["mode"] = 0
                                continue
                            elif b == 8 or b == 127:  # Backspace
                                cw = cursor_metrics["char_w"]
                                ch = cursor_metrics["char_h"]
                                if cursor["col"] > 0:
                                    cursor["col"] -= 1
                                    pygame.draw.rect(canvas, safe_color(cur_text_bg), (int(cursor["col"] * cw), int(cursor["row"] * ch), int(cw) + 1, int(ch) + 1))
                                continue

                            # Tektronix Vector Mode (modes 1..8)
                            if 1 <= tek["mode"] <= 8:
                                tag = (b >> 5) & 3
                                if tag != 0:
                                    # Coordinate skipping rules
                                    if tek["mode"] == 1 and tag != 1: tek["mode"] = 2
                                    if tek["mode"] == 3 and tag == 3:
                                        tek["mode"] = 2
                                        tek["xy4014"] = tek["yl"]
                                    if tek["mode"] == 2 and tag != 3: tek["mode"] = 3
                                    if tek["mode"] == 3 and tag != 1: tek["mode"] = 4
                                    if tek["mode"] == 5 and tag != 1: tek["mode"] = 6
                                    if tek["mode"] == 7 and tag == 3:
                                        tek["mode"] = 6
                                        tek["xy4014"] = tek["yl"]
                                    if tek["mode"] == 6 and tag != 3: tek["mode"] = 7
                                    if tek["mode"] == 7 and tag != 1: tek["mode"] = 8
                                else:
                                    if b == 29: tek["mode"] = 1
                                    continue

                                m = tek["mode"]
                                if m == 1:
                                    tek["yh"] = (b & 31) << 5
                                    tek["mode"] += 1
                                elif m == 2:
                                    tek["yl"] = (b & 31)
                                    tek["mode"] += 1
                                elif m == 3:
                                    if tag == 1: tek["xh"] = (b & 31) << 5
                                    tek["mode"] += 1
                                elif m == 4:
                                    tek["xl"] = (b & 31)
                                    tekX = tek["xh"] + tek["xl"]
                                    tekY = tek["yh"] + tek["yl"]
                                    tek["x0"] = (tekX * (TEK_W - 1)) // 1023
                                    tek["y0"] = (TEK_H - 1) - ((tekY * (TEK_H - 1)) // 779)
                                    tek["mode"] = 5
                                elif m == 5:
                                    if tag != 0:
                                        tek["yh"] = (b & 31) << 5
                                        tek["mode"] += 1
                                elif m == 6:
                                    tek["yl"] = (b & 31)
                                    tek["mode"] += 1
                                elif m == 7:
                                    tek["xh"] = (b & 31) << 5
                                    tek["mode"] += 1
                                elif m == 8:
                                    tek["xl"] = (b & 31)
                                    tekX = tek["xh"] + tek["xl"]
                                    tekY = tek["yh"] + tek["yl"]
                                    tek["x2"] = (tekX * (TEK_W - 1)) // 1023
                                    tek["y2"] = (TEK_H - 1) - ((tekY * (TEK_H - 1)) // 779)
                                    pygame.draw.aaline(canvas, COLOR_VECTOR,
                                                       (tek["x0"], tek["y0"]),
                                                       (tek["x2"], tek["y2"]))
                                    tek["x0"] = tek["x2"]
                                    tek["y0"] = tek["y2"]
                                    tek["mode"] = 5

                            # Alpha Text Mode
                            elif tek["mode"] == 0:
                                fnt = cursor_metrics["font"]
                                cw = cursor_metrics["char_w"]
                                ch = cursor_metrics["char_h"]
                                c_cols = cursor_metrics["cols"]
                                c_rows = cursor_metrics["rows"]
                                if 32 <= b <= 126:
                                    char = chr(b)
                                    x = int(cursor["col"] * cw)
                                    y = int(cursor["row"] * ch)
                                    pygame.draw.rect(canvas, safe_color(cur_text_bg), (x, y, int(cw) + 1, int(ch) + 1))
                                    glyph = fnt.render(char, True, safe_color(cur_text_fg))
                                    canvas.blit(glyph, (x, y))
                                    cursor["col"] += 1
                                    if cursor["col"] >= c_cols:
                                        cursor["col"] = 0
                                        cursor["row"] += 1
                                        if cursor["row"] >= c_rows:
                                            canvas.scroll(0, -int(ch))
                                            pygame.draw.rect(canvas, safe_color(cur_text_bg), (0, TEK_H - int(ch), TEK_W, int(ch)))
                                            cursor["row"] = c_rows - 1
                        except Exception:
                            pass
            except Exception:
                time.sleep(0.01)

    reader_thread = threading.Thread(target=serial_reader, daemon=True)
    reader_thread.start()

    clock = pygame.time.Clock()

    while running[0]:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running[0] = False
                break
            elif event.type == pygame.VIDEORESIZE:
                win_w, win_h = event.w, event.h
                window = pygame.display.set_mode((win_w, win_h), pygame.RESIZABLE)
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_F9:
                    if ser and not is_wifi:
                        new_baud = 921600 if current_baud[0] == 115200 else 115200
                        print(f"[VDP Monitor] Switching baud rate: {current_baud[0]} -> {new_baud} baud...")
                        with canvas_lock:
                            try:
                                ser.baudrate = new_baud
                                ser.reset_input_buffer()
                                ser.reset_output_buffer()
                                current_baud[0] = new_baud
                                title = f"Agon Light 2 - Live VDP Screen Monitor [{args.port} @ {new_baud} baud (F9: toggle)]"
                                pygame.display.set_caption(title)
                                print(f"[VDP Monitor] Serial port now active at {new_baud} baud!")
                            except Exception as ex:
                                print(f"[VDP Monitor] Could not switch baudrate: {ex}")
                    continue

                payload = None
                if event.key == pygame.K_RETURN or event.key == pygame.K_KP_ENTER:
                    payload = b"\r"
                elif event.key == pygame.K_BACKSPACE:
                    payload = b"\x08"
                elif event.key == pygame.K_ESCAPE:
                    payload = b"\x1B"
                elif event.key == pygame.K_UP:
                    payload = b"\x0B"
                elif event.key == pygame.K_DOWN:
                    payload = b"\x0A"
                elif event.key == pygame.K_LEFT:
                    payload = b"\x08"
                elif event.key == pygame.K_RIGHT:
                    payload = b"\x15"
                elif event.key == pygame.K_TAB:
                    payload = b"\t"
                elif event.key == pygame.K_c and (pygame.key.get_mods() & pygame.KMOD_CTRL):
                    payload = b"\x03"
                elif event.unicode:
                    payload = event.unicode.encode("latin1", errors="ignore")

                if payload:
                    stream_write(payload)

        # Thread-safe canvas scaling and rendering
        with canvas_lock:
            scaled_surface = pygame.transform.scale(canvas, (win_w, win_h))
        window.blit(scaled_surface, (0, 0))
        pygame.display.flip()
        clock.tick(60)

    if sock:
        try: sock.close()
        except Exception: pass
    if ser:
        try: ser.close()
        except Exception: pass
    pygame.quit()
    print("[VDP Monitor] Closed.")

if __name__ == "__main__":
    main()
