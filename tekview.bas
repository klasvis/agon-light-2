10 REM ==============================================
20 REM     TEKTRONIX 4014 VECTOR GRAPHICS VIEWER
30 REM ==============================================
40 MODE 2 : CLS
50 PRINT "=============================================="
60 PRINT "   TEKTRONIX 4014 VECTOR GRAPHICS VIEWER      "
70 PRINT "=============================================="
80 PRINT
90 PRINT "Kies een vector-tekening om te bekijken:"
100 PRINT " 1. USS Enterprise (starship.plt)"
110 PRINT " 2. Snoopy (snoopy.plt)"
120 PRINT " 3. 3D Vector Globe (gplanet.plt)"
130 PRINT " 4. 3D Slinky Coil (slinky.plt)"
140 PRINT " 5. Geometric Art (pretty.plt)"
150 PRINT " 6. USA State Map (usmap.plt)"
160 PRINT " 7. Eigen bestand invoeren..."
170 PRINT " Q. Terug naar MOS"
180 PRINT
190 PRINT "Keuze: ";
200 K$ = GET$ : PRINT K$
210 F$ = ""
220 IF K$ = "1" THEN F$ = "starship.plt"
230 IF K$ = "2" THEN F$ = "snoopy.plt"
240 IF K$ = "3" THEN F$ = "gplanet.plt"
250 IF K$ = "4" THEN F$ = "slinky.plt"
260 IF K$ = "5" THEN F$ = "pretty.plt"
270 IF K$ = "6" THEN F$ = "usmap.plt"
280 IF K$ = "7" THEN INPUT "Bestandsnaam: ", F$
290 IF K$ = "Q" OR K$ = "q" THEN END
300 IF F$ = "" THEN GOTO 40
310 :
320 H% = OPENIN(F$)
330 IF H% = 0 THEN
340   PRINT "Fout: Bestand '"; F$; "' niet gevonden!"
350   PRINT "Druk op een toets...": K$ = GET$: GOTO 40
360 ENDIF
370 :
380 MODE 2 : CLS
390 REM Zet Tektronix Vector Decoder AAN met P31 Phosphor Green
400 VDU 23, 0, &FC, 2
410 :
420 REM Stream het vector-bestand naar de VDU
430 REPEAT
440   B% = BGET#H%
450   VDU B%
460 UNTIL EOF#H%
470 CLOSE#H%
480 :
490 REM Wacht tot de gebruiker op een toets drukt
500 K$ = GET$
510 :
520 REM Zet Tektronix Vector Decoder UIT en herstel scherm
530 VDU 23, 0, &FC, 0
540 GOTO 40
