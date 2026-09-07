10 MODE 8 : CLS
20 PRINT "========================================="
30 PRINT "   AGON VDP BITMAP DEMO: RETRO SPRITE   "
40 PRINT "========================================="
50 PRINT
60 PRINT "1. Genereren van 16x16 RGBA bitmap in VDP..."
70 PROC_maak_schip(1)
80 PRINT "   Bitmap ID 1 succesvol aangemaakt!"
90 PRINT
100 PRINT "2. Tekenen op het scherm (VDU 23, 27, 3):"
110 FOR I%=1 TO 7
120   VDU 23, 27, 0, 1
130   VDU 23, 27, 3, (15 + I% * 35); 90;
140 NEXT I%
150 PRINT
160 PRINT "3. Klaar! Kijk naar je beeldscherm!"
170 END
500 DEF PROC_maak_schip(id%)
510   LOCAL Y%, X%, r$, c$
520   RESTORE 1000
530   VDU 23, 27, 0, id%
540   VDU 23, 27, 1, 16; 16;
550   FOR Y% = 1 TO 16
560     READ r$
570     FOR X% = 1 TO 16
580       c$ = MID$(r$, X%, 1)
590       IF c$ = "Y" THEN VDU 255, 230, 0, 255
600       IF c$ = "B" THEN VDU 0, 130, 255, 255
610       IF c$ = "W" THEN VDU 255, 255, 255, 255
620       IF c$ = "R" THEN VDU 255, 50, 0, 255
630       IF c$ = "." THEN VDU 0, 0, 0, 0
640     NEXT X%
650   NEXT Y%
660 ENDPROC
1000 DATA "......YYYY......"
1010 DATA ".....YYYYYY....."
1020 DATA ".....YYWWYY....."
1030 DATA "....BBBYYBBB...."
1040 DATA "...BBBBBBBBBB..."
1050 DATA "..BBBBBBBBBBBB.."
1060 DATA ".BBBBWWBBWWBBBB."
1070 DATA "BBBBBWWBBWWBBBBB"
1080 DATA "BBBBBBBBBBBBBBBB"
1090 DATA ".BB.BBBBBBBB.BB."
1100 DATA ".B..BBBBBBBB..B."
1110 DATA "....BB....BB...."
1120 DATA "....RR....RR...."
1130 DATA "...RRRR..RRRR..."
1140 DATA "....RR....RR...."
1150 DATA ".....R....R....."
