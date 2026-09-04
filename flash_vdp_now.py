import os
import shutil
import subprocess
import sys
import time

script_dir = os.path.dirname(os.path.abspath(__file__))

# 1. Vind firmware.bin (in hoofdmap of agon-vdp build)
bin_path = os.path.join(script_dir, "firmware.bin")
if not os.path.exists(bin_path):
    bin_path = os.path.join(script_dir, "agon-vdp", ".pio", "build", "esp32dev", "firmware.bin")

if not os.path.exists(bin_path):
    print(f"[Error] Kan firmware.bin niet vinden in {script_dir}!")
    sys.exit(1)

# 2. COM poort (standaard COM4, of op te geven als argument: python flash_vdp_now.py COM3)
port = sys.argv[1] if len(sys.argv) > 1 else "COM4"

# 3. Vind esptool (PlatformIO pad, PATH, of python -m esptool)
pio_esp = os.path.expanduser("~/.platformio/packages/tool-esptoolpy/esptool.py")
pio_py = os.path.expanduser("~/.platformio/penv/Scripts/python.exe")

if shutil.which("esptool.py"):
    cmd = f'esptool.py --chip esp32 --port {port} --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size 4MB 0x10000 "{bin_path}"'
elif os.path.exists(pio_esp) and os.path.exists(pio_py):
    cmd = f'"{pio_py}" "{pio_esp}" --chip esp32 --port {port} --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size 4MB 0x10000 "{bin_path}"'
else:
    cmd = f'"{sys.executable}" -m esptool --chip esp32 --port {port} --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size 4MB 0x10000 "{bin_path}"'

print("========================================================")
print("       Agon Light 2 - ESP32 VDP Firmware Flasher        ")
print("========================================================")
print(f"Firmware: {bin_path}")
print(f"Port:     {port}")
print("Commando: " + cmd)
print("\n[Flash] ESP32 upload wordt gestart...")
print("[Flash] Druk eventueel kort op RESET2 op het Agon board als hij zoekt naar verbinding!")

success = False
for attempt in range(1, 25):
    print(f"\n[Poging {attempt}/25] Verbinden met ESP32 op {port}...")
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    out, _ = p.communicate()
    print(out)
    if "Hash of data verified" in out or "Leaving..." in out:
        success = True
        print("\n[Flash] SUCCESS! VDP Firmware met Tektronix 4014 Decoder is succesvol geflasht!")
        break
    time.sleep(0.5)

if not success:
    print(f"\n[Flash] Kon na 25 pogingen geen verbinding maken op {port}.")
    print("Controleer of de COM poort klopt (bijv: python flash_vdp_now.py COM3) en of het bordje aangesloten is.")
