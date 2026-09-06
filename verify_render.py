import pygame
import os

os.environ["SDL_VIDEODRIVER"] = "dummy" # Headless rendering
pygame.init()
pygame.font.init()

TEK_W = 1024
TEK_H = 780
canvas = pygame.Surface((TEK_W, TEK_H))
canvas.fill((10, 20, 12))

cursor_metrics = {
    "cols": 80,
    "rows": 30,
    "char_w": TEK_W / 80,
    "char_h": TEK_H / 30,
    "font": pygame.font.SysFont("Consolas", 18)
}
cursor = {"col": 0, "row": 0}
cur_text_fg = [255, 255, 255]
cur_text_bg = [0, 0, 0]
cur_gfx_fg  = [255, 255, 255]
cur_gfx_bg  = [0, 0, 0]
bitmaps = {}

# Import the handler from agon_monitor logic
# Read the captured stream from test_boerderij_stream
from test_boerderij_stream import raw_data

ext_buf = bytearray()
in_ext = False

def handle_cmd(cmd_str):
    parts = cmd_str.strip().split(" ")
    op = parts[0]
    if op == "C" and len(parts) >= 4:
        cur_gfx_fg[0], cur_gfx_fg[1], cur_gfx_fg[2] = int(parts[1]), int(parts[2]), int(parts[3])
    elif op == "BC" and len(parts) >= 4:
        cur_gfx_bg[0], cur_gfx_bg[1], cur_gfx_bg[2] = int(parts[1]), int(parts[2]), int(parts[3])
    elif op == "K" and len(parts) >= 4:
        cur_text_fg[0], cur_text_fg[1], cur_text_fg[2] = int(parts[1]), int(parts[2]), int(parts[3])
    elif op == "B" and len(parts) >= 4:
        cur_text_bg[0], cur_text_bg[1], cur_text_bg[2] = int(parts[1]), int(parts[2]), int(parts[3])
    elif op == "J" and len(parts) >= 3:
        cursor["col"] = int(parts[1])
        cursor["row"] = int(parts[2])
    elif op == "X":
        canvas.fill(tuple(cur_text_bg))
    elif op == "M" and len(parts) >= 6:
        m_cols = int(parts[4])
        m_rows = int(parts[5])
        if m_cols > 0 and m_rows > 0:
            cursor_metrics["cols"] = m_cols
            cursor_metrics["rows"] = m_rows
            cursor_metrics["char_w"] = TEK_W / m_cols
            cursor_metrics["char_h"] = TEK_H / m_rows
            cursor_metrics["font"] = pygame.font.SysFont("Consolas", max(10, int(cursor_metrics["char_h"] * 0.85)))
    elif op == "CLS":
        if len(parts) >= 4:
            cur_text_bg[0], cur_text_bg[1], cur_text_bg[2] = int(parts[1]), int(parts[2]), int(parts[3])
        canvas.fill(tuple(cur_text_bg))
    elif op == "CLG":
        if len(parts) >= 4:
            cur_gfx_bg[0], cur_gfx_bg[1], cur_gfx_bg[2] = int(parts[1]), int(parts[2]), int(parts[3])
        canvas.fill(tuple(cur_gfx_bg))
    elif op == "R" and len(parts) >= 6:
        x1, y1, x2, y2 = int(parts[1]), int(parts[2]), int(parts[3]), int(parts[4])
        filled = (int(parts[5]) != 0)
        rx = min(x1, x2)
        ry = min(y1, y2)
        rw = max(1, abs(x2 - x1) + 1)
        rh = max(1, abs(y2 - y1) + 1)
        pygame.draw.rect(canvas, tuple(cur_gfx_fg), (rx, ry, rw, rh), 0 if filled else 1)
    elif op == "CI" and len(parts) >= 5:
        cx, cy, r = int(parts[1]), int(parts[2]), int(parts[3])
        filled = (int(parts[4]) != 0)
        if r > 0:
            pygame.draw.circle(canvas, tuple(cur_gfx_fg), (cx, cy), r, 0 if filled else 1)
    elif op == "BM" and len(parts) >= 6:
        b_id = int(parts[1])
        b_fmt = int(parts[2])
        bw = int(parts[3])
        bh = int(parts[4])
        raw = bytes.fromhex(parts[5])
        if b_fmt == 0 and len(raw) >= bw * bh * 4:
            surf = pygame.image.frombuffer(raw, (bw, bh), "RGBA").convert_alpha()
            bitmaps[b_id] = surf
    elif op == "BD" and len(parts) >= 4:
        b_id = int(parts[1])
        bx = int(parts[2])
        by = int(parts[3])
        bw = int(parts[4]) if len(parts) > 4 else None
        bh = int(parts[5]) if len(parts) > 5 else None
        if b_id in bitmaps:
            surf = bitmaps[b_id]
            if bw and bh and (bw != surf.get_width() or bh != surf.get_height()):
                scaled = pygame.transform.scale(surf, (max(1, bw), max(1, bh)))
                canvas.blit(scaled, (bx, by))
            else:
                canvas.blit(surf, (bx, by))

for b in raw_data:
    if in_ext:
        if b == 10 or b == 13:
            in_ext = False
            try:
                handle_cmd(ext_buf.decode('latin1'))
            except Exception:
                pass
            ext_buf.clear()
        elif b == 0x1E:
            try:
                handle_cmd(ext_buf.decode('latin1'))
            except Exception:
                pass
            ext_buf.clear()
        else:
            ext_buf.append(b)
        continue
    if b == 0x1E:
        in_ext = True
        ext_buf.clear()
        continue
    if 32 <= b <= 126:
        char = chr(b)
        cw = cursor_metrics["char_w"]
        ch = cursor_metrics["char_h"]
        x = int(cursor["col"] * cw)
        y = int(cursor["row"] * ch)
        glyph = cursor_metrics["font"].render(char, True, tuple(cur_text_fg))
        canvas.blit(glyph, (x, y))
        cursor["col"] += 1

out_png = r"C:\agon\boerderij_monitor_render.png"
pygame.image.save(canvas, out_png)
print("Saved screenshot to:", out_png)
