# 🚜 Agon Light 2 — Boerderij & High-Speed Graphics Suite

Een complete grafische suite voor de **Agon Light 2** (eZ80 + ESP32 VDP) met bliksemsnelle 24-bit ADL bitmap-weergave, een retro boerderij-screensaver diashow, een interactief pixel-art landschap, een Tektronix vector-viewer en automatische Python conversie-tools.

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

---

## 🚀 Hoe gebruik je het op de Agon Light 2?

### Stap 1: Bestanden op de MicroSD-kaart zetten
Steek de MicroSD-kaart in je PC en dubbelklik op `kopieer_naar_sd.bat` in `C:\agon\`.

### Stap 2: Standaard opstarten in 24-bit BBC BASIC
Zorg dat `autoexec.txt` op de SD-kaart het volgende bevat:
```text
load basic24.bin
run
```
De Agon start bij het inschakelen nu direct op met **438 KB vrij werkgeheugen**.

### Stap 3: Diashow starten
Typ in BBC BASIC:
```basic
LOAD "FOTOSHOW.BAS"
RUN
```

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

## 📜 Licentie
Open source voor de hele Agon Light & retrocomputing community!
