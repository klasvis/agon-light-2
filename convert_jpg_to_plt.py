#!/usr/bin/env python3
"""
Convert any JPG/PNG image into an authentic Tektronix 4014 vector plot (.plt)
Usage:
  python convert_jpg_to_plt.py input.jpg [output.plt]
"""

import sys
import os
import cv2
import numpy as np

def convert_image_to_plt(input_path, output_path=None, threshold_mode="canny", max_points=12000):
    if output_path is None:
        base, _ = os.path.splitext(input_path)
        output_path = base + ".plt"

    print(f"[Vectorize] Loading image: {input_path}")
    img = cv2.imread(input_path)
    if img is None:
        raise FileNotFoundError(f"Could not open image: {input_path}")

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Edge detection
    if threshold_mode == "canny":
        # Bilateral filter preserves sharp edges while eliminating camera/JPEG noise
        filtered = cv2.bilateralFilter(gray, 7, 50, 50)
        edges = cv2.Canny(filtered, 40, 120)
    else:
        # Otsu thresholding for stark black/white line art
        _, edges = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY_INV)

    # Find content bounding box
    coords = np.argwhere(edges > 0)
    if len(coords) == 0:
        print("[Vectorize] Warning: No edges found in image!")
        return

    y_min, x_min = coords.min(axis=0)
    y_max, x_max = coords.max(axis=0)
    src_w = max(1, x_max - x_min)
    src_h = max(1, y_max - y_min)

    # Screen target dimensions (1023 x 779 Tektronix 4014)
    dst_w = 960
    dst_h = 700
    scale = min(dst_w / src_w, dst_h / src_h)
    actual_w = src_w * scale
    actual_h = src_h * scale
    x_offset = (1023 - actual_w) / 2.0
    y_offset = (779 - actual_h) / 2.0

    # Extract contours
    contours, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_TC89_KCOS)

    # Simplify with Ramer-Douglas-Peucker algorithm
    epsilon = 1.2
    polylines = []
    for c in contours:
        approx = cv2.approxPolyDP(c, epsilon, False)
        if len(approx) >= 2:
            pts = []
            for pt in approx:
                px, py = pt[0]
                tx = x_offset + (px - x_min) * scale
                ty = 779.0 - (y_offset + (py - y_min) * scale) # Invert Y for Tektronix
                pts.append((tx, ty))
            polylines.append(pts)

    total_pts = sum(len(p) for p in polylines)
    print(f"[Vectorize] Traced {len(polylines)} vector lines, {total_pts} total coordinates")

    # Encode Tektronix 4014 byte stream
    data = bytearray()
    # 1. Page erase (ESC FF)
    data.extend([0x1B, 0x0C])

    # 2. Encode polylines
    for poly in polylines:
        # Switch to vector mode (GS = 0x1D) -> first coord is a dark beam move
        data.append(0x1D)
        for x, y in poly:
            ix = max(0, min(1023, int(round(x))))
            iy = max(0, min(779, int(round(y))))
            hy = 0x20 | ((iy >> 5) & 0x1F)
            ly = 0x60 | (iy & 0x1F)
            hx = 0x20 | ((ix >> 5) & 0x1F)
            lx = 0x40 | (ix & 0x1F)
            data.extend([hy, ly, hx, lx])

    with open(output_path, "wb") as f:
        f.write(data)

    print(f"[Vectorize] Successfully created: {output_path} ({len(data):,} bytes)")

    # Also copy to SD card if D: is available
    if os.path.exists(r"D:\\"):
        sd_out = os.path.join(r"D:\\", os.path.basename(output_path))
        try:
            with open(sd_out, "wb") as f:
                f.write(data)
            print(f"[Vectorize] Copied to SD-kaart: {sd_out}")
        except Exception as e:
            print(f"[Vectorize] Could not copy to SD: {e}")

    return output_path

if __name__ == "__main__":
    inp = sys.argv[1] if len(sys.argv) > 1 else r"C:\agon\voorbeeld.jpg"
    out = sys.argv[2] if len(sys.argv) > 2 else r"C:\agon\voorbeeld.plt"
    convert_image_to_plt(inp, out)
