#!/usr/bin/env python3
"""
Agon Light 2 - Interactieve Seriële Terminal voor VS Code
Werkt direct op Windows, Linux en macOS.
Gebruik:
  python agon_terminal.py [COM_POORT]
"""

import sys
import time
import threading
import serial
import serial.tools.list_ports

def find_agon_port():
    ports = list(serial.tools.list_ports.comports())
    for p in ports:
        desc = (p.description or "").lower()
        if "ch340" in desc or "cp210" in desc or "usb-serial" in desc or "uart" in desc:
            return p.device
    if ports:
        return ports[0].device
    return "COM4"

def main():
    port = sys.argv[1] if len(sys.argv) > 1 else find_agon_port()
    baud = 115200

    print("=" * 60)
    print(f" Agon Light 2 Terminal — Verbinding met {port} ({baud} baud)")
    print(" Typ commando's en druk op Enter.")
    print(" Typ 'RESET' om de Agon te herstarten via DTR/RTS.")
    print(" Typ 'EXIT' om de terminal te sluiten.")
    print("=" * 60)

    try:
        s = serial.Serial(port, baud, timeout=0.1)
    except Exception as e:
        print(f"[Fout] Kon {port} niet openen: {e}")
        print("\nBeschikbare poorten:")
        for p in serial.tools.list_ports.comports():
            print(f"  - {p.device}: {p.description}")
        return

    running = True

    def reader():
        while running:
            try:
                if s.in_waiting:
                    data = s.read(s.in_waiting).decode('latin1', errors='replace')
                    sys.stdout.write(data)
                    sys.stdout.flush()
                time.sleep(0.01)
            except:
                break

    t = threading.Thread(target=reader, daemon=True)
    t.start()

    # Stuur een enter om prompt op te vragen
    s.write(b"\r\n")

    try:
        while True:
            cmd = input()
            if cmd.strip().upper() == "EXIT":
                break
            elif cmd.strip().upper() == "RESET":
                print("[Terminal] Herstart Agon...")
                s.setDTR(False)
                s.setRTS(True)
                time.sleep(0.1)
                s.setRTS(False)
            else:
                s.write((cmd + "\r\n").encode('latin1'))
    except (KeyboardInterrupt, EOFError):
        pass
    finally:
        running = False
        s.close()
        print("\n[Terminal] Verbinding gesloten.")

if __name__ == "__main__":
    main()
