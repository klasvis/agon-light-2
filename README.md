# 🚜 Agon Light 2 — Boerderij & High-Speed Graphics Suite

Een complete grafische suite voor de **Agon Light 2** (eZ80 + ESP32 VDP) met bliksemsnelle 24-bit ADL bitmap-weergave, een retro boerderij-screensaver diashow, een interactief pixel-art landschap, een Tektronix vector-viewer en automatische Python conversie-tools.

---

## 💻 Direct aan de slag op een andere PC (bijv. in Borne met VS Code)

Heb je een andere computer (zoals in Borne)? Dan kun je binnen 1 minuut direct weer verder:

### 1. Download & Open in VS Code
* Download de repository als **ZIP** (via de groene knop *Code -> Download ZIP* op GitHub) en pak hem uit, of clone hem met Git:
  ```bash
  git clone https://github.com/klasvis/agon-light-2.git
  ```
* Open de map in **VS Code** (`code .`).
* VS Code herkent automatisch de instellingen in `.vscode/`:
  - Aanbevolen extensies: *BBC BASIC for Z80* en *Python*.
  - Handige sneltoetsen en taken via `Ctrl+Shift+B` (*Kopieer naar SD*, *Start Terminal*).

### 2. Python-benodigdheden installeren (1 klik)
Dubbelklik op **`install_requirements.bat`** (of typ `pip install -r requirements.txt`). Dit installeert `pyserial` en `Pillow`.

### 3. SD-kaart klaarmaken in 1 seconde
In de map **`sdcard/`** staat een complete, kant-en-klare MicroSD-kaart image met:
- Het 24-bit besturingssysteem (`basic24.bin`, `autoexec.txt`)
- Alle 4 de foto's (`boerderij.rgb`, `molen.rgb`, `koeien.rgb`, `trekker.rgb`)
- Alle programma's (`FOTOSHOW.BAS`, `SNEL24.BAS`, `BOERDERIJ.BAS`, etc.)

👉 **Kopieer simpelweg de inhoud van de map `sdcard/` naar de hoofdmap van je MicroSD-kaart.** Stop de kaart in de Agon Light 2 en hij start direct op in 24-bit BASIC met 438 KB RAM!

### 4. Agon bedienen vanuit VS Code
Open de ingebouwde terminal in VS Code (`Ctrl+``) en typ:
```bash
python agon_terminal.py
```
Dit zoekt automatisch de juiste USB-poort (bijv. COM3, COM4) en geeft je een live interactief venster met de Agon Light 2. Typ `RESET` om de Agon te herstarten.

---

## ✨ Wat zit er in dit project?

### 1. ⚡ Bliksemsnelle 24-bit Bitmap Loader (`SNEL24.BAS` & `FOTOSHOW.BAS`)
- Maakt gebruik van de **24-bit ADL modus** van de eZ80 processor via `basic24.bin`, waardoor **438 KB vrij SRAM** beschikbaar is.
- Laadt een complete **160×120 RGBA (76.800 bytes)** kleurenfoto in **0,54 seconden** van de SD-kaart naar RAM (`*LOAD foto.rgb &50000`).
- Streamt met een geoptimaliseerde eZ80 machinetaal-routine (`RST.LIS 10h` / `DEFB &49 : RST &10`) alle 76.800 bytes in **0,84 seconden** direct naar de ESP32 VDP videokaart.
- **Totale laadtijd: 1,38 seconden** (meer dan **18× sneller** dan de standaard ~25 seconden via byte-voor-byte BASIC!).

### 2. 🖼️ Retro Boerderij Diashow / Screensaver (`FOTOSHOW.BAS`)
Draait als een rustgevende screensaver op je Agon monitor met 4 Hollandse boerderijtaferelen in 64 Agon-kleuren:
1. `boerderij.rgb`: De oude houten boerderij met koe en schaap in de voorgrond.
2. `molen.rgb`: Een klassieke molen aan het water met koeien en weidelandschap.
3. `koeien.rgb`: Zwartbonte melkkoeien van dichtbij bij het houten weidehek.
4. `trekker.rgb`: Een rode boerderijtrekker bij de schuur met ronde hooibalen.

*Bediening: wisselt automatisch elke 4 seconden. Druk op `[SPATIE]` voor de volgende foto, of `[ESC]` om te stoppen.*

### 3. 🐄 Interactief Pixel-Art Boerderijlandschap (`BOERDERIJ.BAS`)
- Volledig getekend landschap met rode schuur, weide, bomen, wolken en hekjes.
- Geanimeerde koeien en schapen die bewegen in de weide.

### 4. 📐 Tektronix 4010 Vector Viewer (`tekview.bin`)
- Native 24-bit eZ80 machinetaal viewer.
- Rendert Tektronix plotbestanden (`.plt`) in schermvullend 640×480 groen fosfor.
- Bevat `boerderij.plt` (12 KB, 316 haarscherpe vectorlijnen).

### 5. 🛠️ Python Conversietools (voor op de PC)
- `convert_jpg_to_bitmap.py` + `converteer_naar_rgb.bat`: Sleep elke JPG/PNG foto op het batchbestand om direct een 160×120 Agon `.rgb` bitmap te maken.
- `convert_jpg_to_plt.py` + `converteer_naar_plt.bat`: Zet elke foto automatisch om naar Tektronix vectorlijnen (`.plt`).
- `kopieer_naar_sd.bat`: Kopieert in 1 seconde alle bestanden naar een aangesloten MicroSD-kaart (`D:\`).

### 6. ⚡ ESP32 VDP Firmware & Flasher (`agon-vdp/` & `firmware.bin`)
- Bevat de volledige C++ broncode voor de Agon VDP videoprocessor (ESP32) inclusief onze ingebouwde **Tektronix 4014 vector decoder** (`video/tektronix.h`).
- **`firmware.bin`**: De kant-en-klaar gecompileerde ESP32 VDP firmware binary.
- **`flash_vdp_now.py`**: Flasht met 1 commando (`python flash_vdp_now.py COM4`) de nieuwste firmware direct naar de ESP32 over de USB-kabel.
- Kan direct geopend en gecompileerd worden in VS Code met de **PlatformIO** extensie via de configuratie in `agon-vdp/platformio.ini`.

---

## 🔬 Hoe werkt de snelle transfer onder de motorkap?

```
[ MicroSD Kaart ] 
       │  (OSCLI LOAD &50000 — 0,54s)
       ▼
[ eZ80 SRAM &50000 ] 
       │  (eZ80 Machinecode Loop met RST.LIS 10h — 0,84s)
       ▼
[ ESP32 VDP (Videogeheugen) ]
       │  (VDU 23, 27, 3 — < 1 ms)
       ▼
[ VGA Beeldscherm (64 Kleuren) ]
```

### De 24-bit eZ80 Assembler Routine:
```z80
PUSH IX : PUSH IY
LD HL, &50000     ; 24-bit bronadres in SRAM
LD DE, 300        ; 300 blokken van 256 bytes = 76.800 bytes
.outer
LD B, 0
.inner
LD A, (HL)
PUSH BC : PUSH DE : PUSH HL
DEFB &49 : RST &10 ; RST.LIS 10h (eZ80 ADL -> 16-bit MOS VDU output)
POP HL : POP DE : POP BC
INC HL
DJNZ inner
DEC DE
LD A, D : OR E
JR NZ, outer
POP IY : POP IX
RET
```

---

## 📁 Structuur van de Repository

```text
├── .vscode/               # VS Code instellingen, taken en aanbevolen extensies
├── agon-vdp/              # VDU / VDP ESP32 firmware C++ broncode (PlatformIO)
│   ├── platformio.ini     # PlatformIO ESP32 configuratie
│   └── video/             # C++ broncode (inclusief Tektronix 4014 decoder)
├── firmware.bin           # Gecompileerde ESP32 VDP firmware binary
├── flash_vdp_now.py       # Python script om de ESP32 VDP firmware te flashen
├── sdcard/                # Kant-en-klare bestanden voor de MicroSD-kaart
│   ├── basic24.bin        # 24-bit BBC BASIC (Agon ADL)
│   ├── autoexec.txt       # Automatische opstartcode
│   ├── FOTOSHOW.BAS       # Diashow screensaver
│   ├── SNEL24.BAS         # Snelle bitmap loader demo
│   ├── BOERDERIJ.BAS      # Pixel-art landschap met dieren
│   ├── *.rgb              # Alle 4 de 160x120 64-kleuren foto's
│   └── *.plt              # Tektronix vectorbestanden
├── agon_terminal.py       # Live Agon USB-seriële terminal voor VS Code
├── convert_jpg_to_bitmap.py # Foto naar Agon RGBA converter
├── convert_jpg_to_plt.py    # Foto naar Tektronix vector converter
├── kopieer_naar_sd.bat    # 1-klik kopieertool naar MicroSD
├── install_requirements.bat # Installeer Python packages
├── requirements.txt       # Python dependencies (pyserial, Pillow, esptool)
└── README.md              # Projecthandleiding en documentatie
```

---

## 📜 Licentie
Open source voor de hele Agon Light & retrocomputing community!
