import serial
import time
import sys

print("Connecting to COM4 at 115200 baud...")
try:
    ser = serial.Serial("COM4", 115200, timeout=1.0)
except Exception as e:
    print(f"Error opening COM4: {e}")
    sys.exit(1)

time.sleep(0.5)
ser.reset_input_buffer()

def send_and_read(cmd, wait_time=1.5):
    print(f"\n>>> Sending: {cmd.strip()}")
    ser.write(cmd.encode("latin1") + b"\r")
    start = time.time()
    resp = b""
    while time.time() - start < wait_time:
        if ser.in_waiting:
            chunk = ser.read(ser.in_waiting)
            resp += chunk
            sys.stdout.write(chunk.decode("latin1", errors="replace"))
            sys.stdout.flush()
        time.sleep(0.05)
    return resp

# Exit BBC BASIC to MOS if needed
send_and_read("*BYE", 1.0)
send_and_read("", 0.5)

# Check directory
print("\n--- Listing SD Card firmware.bin ---")
send_and_read("ls -l firmware.bin", 1.5)

# Run flash
print("\n--- Starting VDP Flash ---")
ser.write(b"flash vdp firmware.bin -f\r")

start = time.time()
while time.time() - start < 90.0:
    if ser.in_waiting:
        chunk = ser.read(ser.in_waiting)
        text = chunk.decode("latin1", errors="replace")
        sys.stdout.write(text)
        sys.stdout.flush()
        if "?" in text and ("y/n" in text.lower() or "confirm" in text.lower()):
            time.sleep(0.2)
            ser.write(b"y\r")
            print("\n[Confirmed flash prompt: y]")
        if "reboot" in text.lower() or "reset" in text.lower() or "complete" in text.lower() or "done" in text.lower():
            time.sleep(3.0)
            break
    time.sleep(0.1)

# Clean hardware reset pulse via RTS/DTR
print("\n--- Triggering Clean ESP32 Hardware Reset ---")
ser.setDTR(False)
ser.setRTS(True)
time.sleep(0.15)
ser.setRTS(False)
time.sleep(2.5)

# Read boot messages
print("\n--- Reading Boot Messages ---")
start = time.time()
while time.time() - start < 4.0:
    if ser.in_waiting:
        chunk = ser.read(ser.in_waiting)
        sys.stdout.write(chunk.decode("latin1", errors="replace"))
        sys.stdout.flush()
    time.sleep(0.1)

ser.close()
print("\n--- Flash session completed ---")
