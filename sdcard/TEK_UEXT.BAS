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
350 REM 1. Laad bestand direct in SRAM op &50000
360 PRINT "Laden van "; F$; " ("; L%; " bytes)..."
370 OSCLI "LOAD " + F$ + " 50000"
380 :
390 REM 2. Initialiseer UART1 hardware op UEXT (115200 baud, 8N1)
400 DIM I% 32
410 ?I%=&3E:?(I%+1)=0:?(I%+2)=&D3:?(I%+3)=&D1         : REM OUT (&D1), 0 (Interrupts uit)
420 ?(I%+4)=&3E:?(I%+5)=&83:?(I%+6)=&D3:?(I%+7)=&D3   : REM OUT (&D3), &83 (DLAB aan)
430 ?(I%+8)=&3E:?(I%+9)=&0A:?(I%+10)=&D3:?(I%+11)=&D0 : REM OUT (&D0), 10 (115200 baud LSB)
440 ?(I%+12)=&3E:?(I%+13)=0:?(I%+14)=&D3:?(I%+15)=&D1 : REM OUT (&D1), 0 (MSB)
450 ?(I%+16)=&3E:?(I%+17)=&03:?(I%+18)=&D3:?(I%+19)=&D3: REM OUT (&D3), 3 (8N1, DLAB uit)
460 ?(I%+20)=&3E:?(I%+21)=&07:?(I%+22)=&D3:?(I%+23)=&D2: REM OUT (&D2), 7 (FIFO aan & leeg)
470 ?(I%+24)=&3E:?(I%+25)=&03:?(I%+26)=&D3:?(I%+27)=&D4: REM OUT (&D4), 3 (DTR & RTS actief)
480 ?(I%+28)=&C9                                      : REM RET
490 CALL I%
500 :
510 REM 3. Zend scherm-wis commando (ESC FF) naar tablet
520 DIM S% 32
530 ?S%=&DB:?(S%+1)=&D5:?(S%+2)=&E6:?(S%+3)=&20:?(S%+4)=&28:?(S%+5)=&FA : REM wacht op TX leeg
540 ?(S%+6)=&79:?(S%+7)=&D3:?(S%+8)=&D0:?(S%+9)=&C9                     : REM OUT (&D0), A & RET
550 A%=27 : CALL S% : REM ESC
560 A%=12 : CALL S% : REM FF (Page Erase)
570 :
580 REM 4. Stream de hele tekening vanuit SRAM &50000 naar UART1
590 PRINT "Streamen naar tablet via UEXT..."
600 DIM T% 32
610 ?T%=&21:?(T%+1)=&00:?(T%+2)=&00:?(T%+3)=&05       : REM LD HL, &50000
620 ?(T%+4)=&01:!(T%+5)=L%                            : REM LD BC, L%
630 REM Lus: wacht tot zender vrij is, stuur byte
640 ?(T%+7)=&DB:?(T%+8)=&D5:?(T%+9)=&E6:?(T%+10)=&20:?(T%+11)=&28:?(T%+12)=&FA : REM wacht TX
650 ?(T%+13)=&7E                                      : REM LD A, (HL)
660 ?(T%+14)=&D3:?(T%+15)=&D0                         : REM OUT (&D0), A
670 ?(T%+16)=&23                                      : REM INC HL
680 ?(T%+17)=&0B                                      : REM DEC BC
690 ?(T%+18)=&78                                      : REM LD A, B
700 ?(T%+19)=&B1                                      : REM OR C
710 ?(T%+20)=&20:?(T%+21)=&EF                         : REM JR NZ, Lus
720 ?(T%+22)=&C9                                      : REM RET
730 CALL T%
740 :
750 PRINT "Verzonden! Druk op een toets..."
760 K$ = GET$ : GOTO 40
