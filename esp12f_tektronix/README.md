# Agon Light 2 -> ESP-12F UEXT Wireless Tektronix 4014 Monitor

Dit project maakt van een tablet (of smartphone/laptop) een draadloze Tektronix 4014 vector graphics monitor voor de Agon Light 2 via een ESP-12F boardje op de UEXT-poort.

---

## 1. Bedrading (Agon UEXT <-> ESP-12F)

```
        Agon Light 2 UEXT (bovenaanzicht)
                  ┌─────┐
        3.3V  (1) │ o o │ (2)  GND
     TX (PC0) (3) │ o o │ (4)  RX (PC1)
         SCL  (5) │ o o │ (6)  SDA
        MISO  (7) │ o o │ (8)  MOSI
         SCK  (9) │ o o │ (10) CS
                  └─────┘
```

### Aansluiting:
* **Voeding:** Sluit het ESP-12F bordje aan op een USB-C lader of powerbank.
* **UEXT Pin 2 (GND)** -> **GND** van het ESP-12F bordje.
* **UEXT Pin 3 (TX / PC0)** -> **RX (GPIO 3 / RXD0)** van het ESP-12F bordje.

---

## 2. ESP-12F Flashen (Arduino IDE)

1. Open `esp12f_tektronix.ino` in de Arduino IDE.
2. Selecteer board: **NodeMCU 1.0 (ESP-12E Module)** of **Generic ESP8266 Module**.
3. Installeer de bibliotheek via de Library Manager:
   * **WebSockets** (door *Markus Sattler*)
4. Flash de code naar het ESP-12F bordje via zijn eigen USB-C poort.

---

## 3. Tablet Verbinden

1. Ga op de tablet naar Wi-Fi instellingen en maak verbinding met:
   * **SSID:** `Agon-Tektronix`
   * *(Geen wachtwoord)*
2. Open Safari, Chrome of Firefox en surf naar:
   * **`http://192.168.4.1`**
3. Je ziet direct het retro Tektronix-scherm met de status: `● LIVE TEKTRONIX STREAM (Verbonden)`.

---

## 4. Agon Software Uitvoeren

1. Kopieer `TEK_UEXT.BAS` naar de SD-kaart van je Agon Light 2.
2. Zorg dat de `.plt` bestanden (`starship.plt`, `snoopy.plt`, etc.) in dezelfde map staan.
3. Typ in BASIC:
   ```basic
   RUN "TEK_UEXT.BAS"
   ```
4. Kies een vector-afbeelding; de data wordt over UEXT naar de ESP gestuurd en direct live in oplichtend P31 neon groen op de tablet getekend!
