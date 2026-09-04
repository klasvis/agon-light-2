#!/usr/bin/env python3
"""
Convert any JPG/PNG into an authentic Agon VDP RGBA8888 Bitmap (.rgb)
Usage:
  python convert_jpg_to_bitmap.py input.jpg [width] [height] [output.rgb]
Example:
  python convert_jpg_to_bitmap.py voorbeeld.jpg 32 32 voorbeeld.rgb
"""

import sys
import os
from PIL import Image

def convert_to_agon_bitmap(input_path, width=32, height=32, output_path=None):
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Bestand niet gevonden: {input_path}")

    if output_path is None:
        base, _ = os.path.splitext(input_path)
        output_path = f"{base}_{width}x{height}.rgb"

    print(f"[Bitmap] Laden van afbeelding: {input_path}")
    img = Image.open(input_path).convert('RGBA')

    print(f"[Bitmap] Schalen naar {width}x{height} pixels...")
    img_resized = img.resize((width, height), Image.Resampling.LANCZOS)

    raw_bytes = img_resized.tobytes()
    expected_size = width * height * 4
    assert len(raw_bytes) == expected_size, f"Grootte klopt niet: {len(raw_bytes)} vs {expected_size}"

    with open(output_path, "wb") as f:
        f.write(raw_bytes)

    print(f"[Bitmap] Opgeslagen: {output_path} ({len(raw_bytes):,} bytes, RGBA8888)")

    # Copy to SD card if D: is present
    if os.path.exists(r"D:\\"):
        sd_out = os.path.join(r"D:\\", os.path.basename(output_path))
        try:
            with open(sd_out, "wb") as f:
                f.write(raw_bytes)
            print(f"[Bitmap] Gekopieerd naar SD-kaart: {sd_out}")
        except Exception as e:
            print(f"[Bitmap] Kon niet naar SD kopiëren: {e}")

    return output_path

if __name__ == "__main__":
    inp = sys.argv[1] if len(sys.argv) > 1 else r"C:\agon\voorbeeld.jpg"
    w = int(sys.argv[2]) if len(sys.argv) > 2 else 32
    h = int(sys.argv[3]) if len(sys.argv) > 3 else 32
    out = sys.argv[4] if len(sys.argv) > 4 else None
    convert_to_agon_bitmap(inp, w, h, out)
