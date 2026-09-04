#ifndef TEKTRONIX_H
#define TEKTRONIX_H

#include <Arduino.h>
#include <HardwareSerial.h>
#include <fabgl.h>
#include <math.h>

extern HardwareSerial DBGSerial;
extern bool consoleMode;
extern std::unique_ptr<fabgl::Canvas> canvas;
extern uint16_t canvasW;
extern uint16_t canvasH;

class TekDecoder {
public:
	// Mode state machine from Tek4010:
	// 0: Alpha mode
	// 1..4: Move to (dark vector)
	// 5..8: Draw vector (bright vector)
	// 30: Escape mode
	int mode = 0;
	int savemode = 0;
	int xh = 0, xl = 0, yh = 0, yl = 0, xy4014 = 0;
	int x0 = 0, y0 = 0;
	int x2 = 0, y2 = 0;
	bool active = false;

	// Vector phosphor color: Default Tektronix P31 green (0, 255, 64)
	uint8_t penR = 0;
	uint8_t penG = 255;
	uint8_t penB = 64;

	void start(bool clearScreen = true) {
		active = true;
		mode = 0;
		savemode = 0;
		xh = xl = yh = yl = xy4014 = 0;
		x0 = y0 = x2 = y2 = 0;
		if (clearScreen && canvas) {
			canvas->setBrushColor(RGB888(0, 0, 0));
			canvas->clear();
		}
	}

	void stop() {
		active = false;
		mode = 0;
	}

	bool isActive() const {
		return active;
	}

	void setColor(uint8_t r, uint8_t g, uint8_t b) {
		penR = r; penG = g; penB = b;
	}

	void processByte(uint8_t ch) {
		if (!canvas) return;

		// Return to alpha checks
		if (mode != 0) {
			if (ch == 27) savemode = mode;
			if (ch == 31 || ch == 13 || ch == 27) {
				mode = (ch == 27) ? 30 : 0;
				return;
			}
		}

		// Escape sequence handling
		if (mode == 30) {
			mode = savemode;
			if (ch == 0x0C) { // ESC FF: Page Erase / Clear Screen
				canvas->setBrushColor(RGB888(0, 0, 0));
				canvas->clear();
				x0 = 0;
				y0 = 0;
			}
			return;
		}

		// Control codes
		switch (ch) {
			case 7:  // BEL
				return;
			case 12: // FF: Page Erase
				canvas->setBrushColor(RGB888(0, 0, 0));
				canvas->clear();
				x0 = 0;
				y0 = 0;
				return;
			case 13: // CR
				mode = 0;
				x0 = 0;
				return;
			case 10: // LF
				y0 += 14;
				return;
			case 27: // ESC
				savemode = mode;
				mode = 30;
				return;
			case 29: // GS: Enter Graphics Vector Mode (mode 1 = dark move)
				mode = 1;
				return;
			case 31: // US: Return to Alpha Mode
				mode = 0;
				return;
			case 24: // CAN (Ctrl+X)
			case 3:  // ETX (Ctrl+C)
				stop();
				return;
		}

		// Alpha mode: draw text characters
		if (mode == 0) {
			if (ch >= 32 && ch <= 126) {
				canvas->setPenColor(RGB888(penR, penG, penB));
				canvas->setBrushColor(RGB888(0, 0, 0));
				canvas->drawChar(x0, y0, ch);
				x0 += 8;
			}
			return;
		}

		// Vector Mode (modes 1..8)
		if (mode >= 1 && mode <= 8) {
			int tag = (ch >> 5) & 3;

			if (tag != 0) {
				// Skipping rules from Tek4010
				if ((mode == 1) && (tag != 1)) mode = 2;

				if ((mode == 3) && (tag == 3)) {
					// 4014 extra byte
					mode = 2;
					xy4014 = yl;
				}

				if ((mode == 2) && (tag != 3)) mode = 3;
				if ((mode == 3) && (tag != 1)) mode = 4;

				if ((mode == 5) && (tag != 1)) mode = 6;

				if ((mode == 7) && (tag == 3)) {
					// 4014 extra byte
					mode = 6;
					xy4014 = yl;
				}

				if ((mode == 6) && (tag != 3)) mode = 7;
				if ((mode == 7) && (tag != 1)) mode = 8;
			} else {
				if (ch == 29) mode = 1;
				return;
			}

			// Screen dimensions for scaling
			int sw = canvasW > 0 ? canvasW : canvas->getWidth();
			int sh = canvasH > 0 ? canvasH : canvas->getHeight();
			if (sw <= 0 || sh <= 0) return;

			switch (mode) {
				case 1:
					yh = (ch & 31) << 5;
					mode++;
					break;
				case 2:
					yl = (ch & 31);
					mode++;
					break;
				case 3:
					if (tag == 1) xh = (ch & 31) << 5;
					mode++;
					break;
				case 4: { // End of dark vector: update beam position
					xl = (ch & 31);
					int tekX = xh + xl;
					int tekY = yh + yl;
					x0 = (tekX * (sw - 1)) / 1023;
					y0 = (sh - 1) - ((tekY * (sh - 1)) / 779);
					mode = 5; // Ready for subsequent bright vectors
				} break;
				case 5:
					if (tag != 0) {
						yh = (ch & 31) << 5;
						mode++;
					}
					break;
				case 6:
					yl = (ch & 31);
					mode++;
					break;
				case 7:
					xh = (ch & 31) << 5;
					mode++;
					break;
				case 8: { // End of bright vector: draw line!
					xl = (ch & 31);
					int tekX = xh + xl;
					int tekY = yh + yl;
					x2 = (tekX * (sw - 1)) / 1023;
					y2 = (sh - 1) - ((tekY * (sh - 1)) / 779);

					canvas->setPenColor(RGB888(penR, penG, penB));
					canvas->drawLine(x0, y0, x2, y2);

					x0 = x2;
					y0 = y2;
					mode = 5; // Loop for additional vectors
				} break;
			}
		}
	}
};

extern TekDecoder tekDecoder;

// Functions to send Tektronix escape codes to DBGSerial
inline void tek_write_byte(uint8_t b) {
	DBGSerial.write(b);
}

inline void tek_send_point(int x, int y) {
	if (x < 0) x = 0; else if (x > 1023) x = 1023;
	if (y < 0) y = 0; else if (y > 779) y = 779;
	uint8_t hy = 0x20 | ((y >> 5) & 0x1F);
	uint8_t ly = 0x60 | (y & 0x1F);
	uint8_t hx = 0x20 | ((x >> 5) & 0x1F);
	uint8_t lx = 0x40 | (x & 0x1F);
	tek_write_byte(hy);
	tek_write_byte(ly);
	tek_write_byte(hx);
	tek_write_byte(lx);
}

inline void tek_draw_line(int x1, int y1, int x2, int y2, int sw, int sh, uint8_t r = 255, uint8_t g = 255, uint8_t b = 255) {
	if (!consoleMode || sw < 2 || sh < 2) return;
	int tx1 = (x1 * 1023) / (sw - 1);
	int ty1 = ((sh - 1 - y1) * 779) / (sh - 1);
	int tx2 = (x2 * 1023) / (sw - 1);
	int ty2 = ((sh - 1 - y2) * 779) / (sh - 1);
	tek_write_byte(0x1D);
	tek_send_point(tx1, ty1);
	tek_send_point(tx2, ty2);
	tek_write_byte(0x1F);
}

inline void tek_draw_rect(int x1, int y1, int x2, int y2, int sw, int sh, uint8_t r = 255, uint8_t g = 255, uint8_t b = 255, bool filled = false) {
	if (!consoleMode || sw < 2 || sh < 2) return;
	int tx1 = (x1 * 1023) / (sw - 1);
	int ty1 = ((sh - 1 - y1) * 779) / (sh - 1);
	int tx2 = (x2 * 1023) / (sw - 1);
	int ty2 = ((sh - 1 - y2) * 779) / (sh - 1);
	tek_write_byte(0x1D);
	tek_send_point(tx1, ty1);
	tek_send_point(tx2, ty1);
	tek_send_point(tx2, ty2);
	tek_send_point(tx1, ty2);
	tek_send_point(tx1, ty1);
	tek_write_byte(0x1F);
}

inline void tek_draw_circle(int cx, int cy, int radius, int sw, int sh, uint8_t r = 255, uint8_t g = 255, uint8_t b = 255, bool filled = false) {
	if (!consoleMode || radius <= 0 || sw < 2 || sh < 2) return;
	tek_write_byte(0x1D);
	for (int i = 0; i <= 24; i++) {
		float angle = (i * 6.2831853f) / 24.0f;
		int px = cx + (int)(cos(angle) * radius);
		int py = cy + (int)(sin(angle) * radius);
		int tx = (px * 1023) / (sw - 1);
		int ty = ((sh - 1 - py) * 779) / (sh - 1);
		tek_send_point(tx, ty);
	}
	tek_write_byte(0x1F);
}

inline void tek_draw_triangle(int x1, int y1, int x2, int y2, int x3, int y3, int sw, int sh, uint8_t r = 255, uint8_t g = 255, uint8_t b = 255) {
	if (!consoleMode || sw < 2 || sh < 2) return;
	int tx1 = (x1 * 1023) / (sw - 1);
	int ty1 = ((sh - 1 - y1) * 779) / (sh - 1);
	int tx2 = (x2 * 1023) / (sw - 1);
	int ty2 = ((sh - 1 - y2) * 779) / (sh - 1);
	int tx3 = (x3 * 1023) / (sw - 1);
	int ty3 = ((sh - 1 - y3) * 779) / (sh - 1);
	tek_write_byte(0x1D);
	tek_send_point(tx1, ty1);
	tek_send_point(tx2, ty2);
	tek_send_point(tx3, ty3);
	tek_send_point(tx1, ty1);
	tek_write_byte(0x1F);
}

inline void tek_draw_point(int x, int y, int sw, int sh, uint8_t r = 255, uint8_t g = 255, uint8_t b = 255) {
	if (!consoleMode || sw < 2 || sh < 2) return;
	int tx = (x * 1023) / (sw - 1);
	int ty = ((sh - 1 - y) * 779) / (sh - 1);
	tek_write_byte(0x1D);
	tek_send_point(tx, ty);
	tek_send_point(tx, ty);
	tek_write_byte(0x1F);
}

inline void tek_clear() {
	if (!consoleMode) return;
	tek_write_byte(0x1B);
	tek_write_byte(0x0C);
	tek_write_byte(0x1F);
}

#endif // TEKTRONIX_H
