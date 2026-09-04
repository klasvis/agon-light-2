10 REM ==============================================
20 REM   TEKTRONIX STREAMER NAAR UEXT (ESP-12F)
30 REM ==============================================
40 MODE 2 : CLS
50 PRINT "=============================================="
60 PRINT "     TEKTRONIX 4014 DRAADLOZE STREAMER        "
70 PRINT "=============================================="
80 PRINT
90 PRINT "Kies een bestand om naar tablet te zenden:"
100 PRINT " 1. Hollandse Boerderij (boerderij.plt)"
110 PRINT " 2. USS Enterprise (starship.plt)"
120 PRINT " 3. Snoopy (snoopy.plt)"
130 PRINT " 4. 3D Vector Globe (gplanet.plt)"
140 PRINT " 5. Geometric Art (pretty.plt)"
150 PRINT " 6. USA Map (usmap.plt)"
160 PRINT " Q. Stoppen"
170 PRINT
180 PRINT "Keuze: ";
190 K$ = GET$ : PRINT K$
200 F$ = ""
210 IF K$ = "1" THEN F$ = "boerderij.plt"
220 IF K$ = "2" THEN F$ = "starship.plt"
230 IF K$ = "3" THEN F$ = "snoopy.plt"
240 IF K$ = "4" THEN F$ = "gplanet.plt"
250 IF K$ = "5" THEN F$ = "pretty.plt"
260 IF K$ = "6" THEN F$ = "usmap.plt"
270 IF K$ = "Q" OR K$ = "q" THEN END
280 IF F$ = "" THEN GOTO 40
290 :
300 REM Controleer bestand en bepaal lengte
310 H% = OPENIN(F$)
320 IF H% = 0 THEN PRINT "Bestand niet gevonden!": WAIT 100: GOTO 40
330 L% = EXT#H% : CLOSE#H%
340 :
350 OSCLI "*LOAD " + F$ + " &50000"
360 :
370 REM 1. Open UART1 op UEXT (115200 baud, 8N1)
380 DIM U% 16
390 !U% = 115200
400 ?(U%+3)=8 : ?(U%+4)=1 : ?(U%+5)=0 : ?(U%+6)=0 : ?(U%+7)=0
410 :
420 DIM C% 128
430 P% = C%
440 [
450 OPT 0
460 PUSH IX
470 PUSH IY
480 LD IX, U%
490 LD A, &15
500 DEFB &49
510 RST &08
520 LD A, &18 : LD C, 27 : DEFB &49 : RST &08
530 LD A, &18 : LD C, 12 : DEFB &49 : RST &08
540 LD HL, &50000
550 LD DE, L%
560 .stream_loop
570 LD A, (HL)
580 LD C, A
590 LD A, &18
600 PUSH BC
610 PUSH DE
620 PUSH HL
630 DEFB &49
640 RST &08
650 POP HL
660 POP DE
670 POP BC
680 INC HL
690 DEC DE
700 LD A, D
710 OR E
720 JR NZ, stream_loop
730 POP IY
740 POP IX
750 RET
760 ]
770 :
780 PRINT "Streamen naar tablet via UEXT..."
790 CALL C%
800 PRINT "Klaar! Druk op een toets..."
810 K$ = GET$ : GOTO 40
