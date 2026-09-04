10 REM =========================================================
20 REM     BLIKSEMSNELLE 24-BIT FOTO DIASHOW (SLIDESHOW)       
30 REM =========================================================
40 MODE 8 : CLS
50 REM Initialiseer machinetaal streaming routine
60 DIM c% 80 : P% = c%
70 [
80 OPT 0
90 PUSH IX : PUSH IY
100 LD HL, &50000
110 LD DE, 300
120 .outer
130 LD B, 0
140 .inner
150 LD A, (HL)
160 PUSH BC : PUSH DE : PUSH HL
170 DEFB &49 : RST &10
180 POP HL : POP DE : POP BC
190 INC HL
200 DJNZ inner
210 DEC DE : LD A, D : OR E : JR NZ, outer
220 POP IY : POP IX
230 RET
240 ]
250 REM Lijst met fotos en titels
260 N% = 4
270 DIM f$(4), t$(4)
280 f$(1) = "boerderij.rgb" : t$(1) = "1/4: De Oude Boerderij"
290 f$(2) = "molen.rgb"     : t$(2) = "2/4: Molen aan het Water"
300 f$(3) = "koeien.rgb"    : t$(3) = "3/4: Hollandse Koeien in de Weide"
310 f$(4) = "trekker.rgb"   : t$(4) = "4/4: De Rode Trekker bij de Schuur"
320 :
330 REM Hoofdlus van de diashow
340 idx% = 1
350 REPEAT
360   PROC_toon_foto(f$(idx%), t$(idx%))
370   REM Wacht 4 seconden of op spatiebalk
380   t_start% = TIME
390   k% = 0
400   REPEAT
410     k% = INKEY(5)
420   UNTIL k% = 32 OR k% = 27 OR (TIME - t_start% > 400)
430   IF k% = 27 THEN CLS : PRINT "Diashow beeindigd." : END
440   idx% = idx% + 1
450   IF idx% > N% THEN idx% = 1
460 UNTIL FALSE
470 :
500 DEF PROC_toon_foto(bestand$, titel$)
510   LOCAL t0%, t1%, t2%
520   CLS
530   PRINT TAB(2, 1); titel$
540   PRINT TAB(2, 28); "Laden..."
550   t0% = TIME
560   OSCLI "LOAD " + bestand$ + " &50000"
570   t1% = TIME
580   VDU 23, 27, 0, 1
590   VDU 23, 27, 1, 160; 120;
600   CALL c%
610   t2% = TIME
620   VDU 23, 27, 0, 1
630   VDU 23, 27, 3, 80; 40;
640   PRINT TAB(2, 26); "Geladen in: "; (t2%-t0%)/100; "s"
650   PRINT TAB(2, 28); "[SPATIE] = Volgende | [ESC] = Stoppen    "
660 ENDPROC
