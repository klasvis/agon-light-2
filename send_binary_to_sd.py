import serial
import time
import sys

def upload_bin_to_sd(filename, bin_path):
    with open(bin_path, 'rb') as f:
        data = f.read()
    print(f"[Upload] Uploading {filename} ({len(data)} bytes) to Agon SD card...")

    s = serial.Serial('COM4', 115200, timeout=1.0)
    time.sleep(0.3)
    if s.in_waiting:
        s.read(s.in_waiting)

    # Make sure we are in BBC BASIC
    s.write(b'\r\n')
    time.sleep(0.2)
    p = s.read(s.in_waiting or 100).decode('latin1', errors='replace')
    if ">" not in p:
        print("[Upload] Starting BBC BASIC from MOS...")
        s.write(b'LOAD "BASIC.BIN"\r\n')
        time.sleep(0.8)
        s.write(b'RUN\r\n')
        time.sleep(0.8)
        if s.in_waiting:
            s.read(s.in_waiting)

    s.write(b"NEW\r\n")
    time.sleep(0.2)

    basic_code = [
        f'10 F%=OPENOUT("{filename}")',
        '20 REPEAT',
        '30 READ H$',
        '40 IF H$="END" THEN CLOSE#F%:PRINT "Gereed!":END',
        '50 FOR I%=1 TO LEN(H$) STEP 2',
        '60 BPUT#F%, EVAL("&"+MID$(H$,I%,2))',
        '70 NEXT I%',
        '80 UNTIL FALSE'
    ]

    # Convert binary to DATA lines of 64 hex chars (32 bytes)
    hex_str = data.hex().upper()
    line_num = 100
    chunk_size = 64
    for i in range(0, len(hex_str), chunk_size):
        chunk = hex_str[i:i+chunk_size]
        basic_code.append(f'{line_num} DATA "{chunk}"')
        line_num += 10
    basic_code.append(f'{line_num} DATA "END"')

    print(f"[Upload] Sending {len(basic_code)} lines to BBC BASIC...")
    for l in basic_code:
        s.write((l + "\r\n").encode('latin1'))
        time.sleep(0.02)

    time.sleep(0.5)
    if s.in_waiting:
        s.read(s.in_waiting)

    print(f"[Upload] Running generator to write {filename} to SD card...")
    s.write(b"RUN\r\n")
    time.sleep(2.0)
    out = s.read(s.in_waiting or 500).decode('latin1', errors='replace')
    print("[Output]:", out.strip())

    s.write(b"*BYE\r\n")
    time.sleep(0.3)
    s.close()
    print(f"[Upload] {filename} is nu succesvol geschreven naar SD!")

if __name__ == "__main__":
    upload_bin_to_sd("netman96.bin", r"C:\agon\netman96.bin")
