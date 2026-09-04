10 REM ==============================================
20 REM   TEKTRONIX STREAMER NAAR UEXT (ESP-12F)
30 REM ==============================================
40 MODE 2 : CLS
50 PRINT "=============================================="
60 PRINT "     TEKTRONIX 4014 DRAADLOZE STREAMER        "
70 PRINT "=============================================="
80 PRINT
90 PRINT "Kies een bestand om naar tablet te zenden:"
100 PRINT " 1. USS Enterprise (starship.plt)"
110 PRINT " 2. Snoopy (snoopy.plt)"
120 PRINT " 3. 3D Vector Globe (gplanet.plt)"
130 PRINT " 4. Geometric Art (pretty.plt)"
140 PRINT " 5. USA Map (usmap.plt)"
150 PRINT " Q. Stoppen"
160 PRINT
170 PRINT "Keuze: ";
180 K$ = GET$ : PRINT K$
190 F$ = ""
200 IF K$ = "1" THEN F$ = "starship.plt"
210 IF K$ = "2" THEN F$ = "snoopy.plt"
220 IF K$ = "3" THEN F$ = "gplanet.plt"
230 IF K$ = "4" THEN F$ = "pretty.plt"
240 IF K$ = "5" THEN F$ = "usmap.plt"
250 IF K$ = "Q" OR K$ = "q" THEN END
260 IF F$ = "" THEN GOTO 40
270 :
280 H% = OPENIN(F$)
290 IF H% = 0 THEN PRINT "Bestand niet gevonden!": WAIT 100: GOTO 40
300 :
310 REM UART1 openen op UEXT (115200 baud, 8N1) via MOS API 0x15
320 DIM C% 32
330 ?C%=&DD:?(C%+1)=&21:!(C%+2)=C%+9:?(C%+5)=&3E:?(C%+6)=&15:?(C%+7)=&CF:?(C%+8)=&C9
340 !(C%+9)=115200:?(C%+12)=8:?(C%+13)=1:?(C%+14)=0:?(C%+15)=0:?(C%+16)=0
350 CALL C%
360 :
370 PRINT "Streamen naar tablet via UEXT..."
380 REM Wis het scherm op de tablet (ESC FF)
390 PUT 216, 27 : PUT 216, 12
400 :
410 REM Stream alle bytes naar UART1 (UEXT I/O poort &D0 = 208)
420 REPEAT
430   B% = BGET#H%
440   REM Wacht tot UART1 zendbuffer leeg is (LSR bit 5 op poort &D5 = 213)
450   REPEAT UNTIL (INP(213) AND 32) <> 0
460   PUT 208, B%
470 UNTIL EOF#H%
480 CLOSE#H%
490 PRINT "Klaar! Druk op een toets...": K$ = GET$: GOTO 40
