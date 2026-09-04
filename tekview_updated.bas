10 MODE 2 : CLS
20 PRINT "=============================================="
30 PRINT "   TEKTRONIX 4014 VECTOR GRAPHICS VIEWER      "
40 PRINT "=============================================="
50 PRINT
60 PRINT "Klassiekers:"
70 PRINT " 1. USS Enterprise       5. USA State Map"
80 PRINT " 2. Snoopy Peanuts       6. 3D Globe Planet"
90 PRINT " 3. 3D Slinky Coil       7. Mona Lisa"
100 PRINT " 4. Geometric Mandala"
110 PRINT
120 PRINT "NASA Space Collection:"
130 PRINT " A. Apollo Lunar Module  (apollo.plt)"
140 PRINT " B. Space Shuttle OV-102 (shuttle.plt)"
150 PRINT " C. Saturn V Moon Rocket (saturn5.plt)"
160 PRINT " D. NASA 1975 Worm Logo  (nasaworm.plt)"
170 PRINT
180 PRINT " 8. Eigen bestand invoeren..."
190 PRINT " Q. Terug naar MOS"
200 PRINT
210 PRINT "Keuze: ";
220 K$ = GET$ : PRINT K$
230 F$ = ""
240 IF K$ = "1" THEN F$ = "starship.plt"
250 IF K$ = "2" THEN F$ = "snoopy.plt"
260 IF K$ = "3" THEN F$ = "slinky.plt"
270 IF K$ = "4" THEN F$ = "pretty.plt"
280 IF K$ = "5" THEN F$ = "usmap.plt"
290 IF K$ = "6" THEN F$ = "gplanet.plt"
300 IF K$ = "7" THEN F$ = "mona.plt"
310 IF K$ = "A" OR K$ = "a" THEN F$ = "apollo.plt"
320 IF K$ = "B" OR K$ = "b" THEN F$ = "shuttle.plt"
330 IF K$ = "C" OR K$ = "c" THEN F$ = "saturn5.plt"
340 IF K$ = "D" OR K$ = "d" THEN F$ = "nasaworm.plt"
350 IF K$ = "8" THEN INPUT "Bestandsnaam: ", F$
360 IF K$ = "Q" OR K$ = "q" THEN *BYE
370 IF F$ = "" THEN GOTO 10
380 H% = OPENIN(F$)
390 IF H% = 0 THEN PRINT "Bestand niet gevonden!": FOR W%=1 TO 25000: NEXT W%: GOTO 10
400 MODE 2 : CLS
410 VDU 23, 0, &FC, 2
420 REPEAT
430   VDU BGET#H%
440 UNTIL EOF#H%
450 CLOSE#H%
460 K$ = GET$
470 VDU 23, 0, &FC, 0
480 GOTO 10
