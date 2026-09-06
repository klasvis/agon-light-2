10 REM =========================================================
20 REM       DE AGON BOERDERIJ: SCHUUR, KOE & SCHAAP IN DE WEI  
30 REM =========================================================
40 MODE 8 : CLS
50 : 
60 REM --- 1. Teken het landschap (Lucht, Zon, Wei) ---
70 PROC_landschap
80 : 
90 REM --- 2. VDP Bitmaps aanmaken in ESP32 videogeheugen ---
100 PROC_maak_schuur(1)
110 PROC_maak_hek(2)
120 PROC_maak_koe(3)
130 PROC_maak_schaap(4)
140 : 
150 REM --- 3. Plaats de schuur, het hek en de dieren ---
160 REM De rode schuur bij de horizon (X=30, Y=80)
170 VDU 23, 27, 0, 1
180 VDU 23, 27, 3, 30; 80;
190 : 
200 REM Het houten hekje langs de wei
210 VDU 23, 27, 0, 2
220 FOR X%=65 TO 305 STEP 16
230   VDU 23, 27, 3, X%; 98;
240 NEXT X%
250 : 
260 REM De bonte koeien in het malse gras
270 VDU 23, 27, 0, 3
280 VDU 23, 27, 3, 145; 130;
290 VDU 23, 27, 3, 230; 150;
300 : 
310 REM De wollige schapen in de wei
320 VDU 23, 27, 0, 4
330 VDU 23, 27, 3, 50; 145;
340 VDU 23, 27, 3, 100; 170;
350 VDU 23, 27, 3, 185; 180;
360 : 
370 REM Tekstbalk bovenin de lucht
380 COLOUR 15
390 PRINT TAB(2,1); "=== DE AGON BOERDERIJ (VDP BITMAPS) ==="
400 PRINT TAB(2,2); "Schuur, Koe & Schaap in de groene wei!"
410 END
420 : 
500 DEF PROC_landschap
510   REM Blauwe lucht (bovenste helft)
520   GCOL 0, 4
530   MOVE 0, 480 : PLOT 101, 1279, 959
540   REM Gele zon aan de hemel
550   GCOL 0, 3
560   MOVE 1100, 850 : PLOT 157, 1170, 850
570   REM Groene wei (onderste helft)
580   GCOL 0, 2
590   MOVE 0, 0 : PLOT 101, 1279, 480
595 ENDPROC
600 DEF PROC_maak_schuur(id%)
610   LOCAL Y%, X%, r$, c$
620   RESTORE 1000
630   VDU 23, 27, 0, id%
640   VDU 23, 27, 1, 32; 32;
650   FOR Y%=1 TO 32
660     READ r$
670     FOR X%=1 TO 32
680       c$ = MID$(r$, X%, 1)
681       IF c$ = "Y" THEN VDU 255, 215, 0, 255
682       IF c$ = "G" THEN VDU 100, 105, 115, 255
683       IF c$ = "L" THEN VDU 190, 195, 205, 255
684       IF c$ = "R" THEN VDU 190, 30, 30, 255
685       IF c$ = "W" THEN VDU 245, 245, 245, 255
686       IF c$ = "O" THEN VDU 45, 20, 20, 255
687       IF c$ = "D" THEN VDU 90, 20, 20, 255
688       IF c$ = "." THEN VDU 0, 0, 0, 0
690     NEXT X%
695   NEXT Y%
699 ENDPROC
700 DEF PROC_maak_hek(id%)
710   LOCAL Y%, X%, r$, c$
720   RESTORE 1400
730   VDU 23, 27, 0, id%
740   VDU 23, 27, 1, 16; 16;
750   FOR Y%=1 TO 16
760     READ r$
770     FOR X%=1 TO 16
780       c$ = MID$(r$, X%, 1)
781       IF c$ = "N" THEN VDU 190, 140, 80, 255
782       IF c$ = "M" THEN VDU 130, 85, 40, 255
783       IF c$ = "K" THEN VDU 70, 45, 20, 255
784       IF c$ = "." THEN VDU 0, 0, 0, 0
790     NEXT X%
795   NEXT Y%
799 ENDPROC
800 DEF PROC_maak_koe(id%)
810   LOCAL Y%, X%, r$, c$
820   RESTORE 1600
830   VDU 23, 27, 0, id%
840   VDU 23, 27, 1, 24; 16;
850   FOR Y%=1 TO 16
860     READ r$
870     FOR X%=1 TO 24
880       c$ = MID$(r$, X%, 1)
881       IF c$ = "W" THEN VDU 255, 255, 255, 255
882       IF c$ = "B" THEN VDU 25, 25, 25, 255
883       IF c$ = "P" THEN VDU 255, 170, 180, 255
884       IF c$ = "H" THEN VDU 220, 190, 140, 255
885       IF c$ = "K" THEN VDU 15, 15, 15, 255
886       IF c$ = "U" THEN VDU 255, 160, 170, 255
887       IF c$ = "E" THEN VDU 0, 0, 60, 255
888       IF c$ = "." THEN VDU 0, 0, 0, 0
890     NEXT X%
895   NEXT Y%
899 ENDPROC
900 DEF PROC_maak_schaap(id%)
910   LOCAL Y%, X%, r$, c$
920   RESTORE 1800
930   VDU 23, 27, 0, id%
940   VDU 23, 27, 1, 20; 16;
950   FOR Y%=1 TO 16
960     READ r$
970     FOR X%=1 TO 20
980       c$ = MID$(r$, X%, 1)
981       IF c$ = "W" THEN VDU 255, 255, 255, 255
982       IF c$ = "G" THEN VDU 215, 215, 215, 255
983       IF c$ = "B" THEN VDU 35, 35, 35, 255
984       IF c$ = "E" THEN VDU 255, 255, 255, 255
985       IF c$ = "K" THEN VDU 15, 15, 15, 255
986       IF c$ = "." THEN VDU 0, 0, 0, 0
990     NEXT X%
995   NEXT Y%
999 ENDPROC
1000 DATA "...............YY..............."
1010 DATA "...............YY..............."
1020 DATA "..............LLLL.............."
1030 DATA ".............GGGGGG............."
1040 DATA "............GGGGGGGG............"
1050 DATA "...........GGGGGGGGGG..........."
1060 DATA "..........GGGGGGGGGGGG.........."
1070 DATA ".........GGGGGGGGGGGGGG........."
1080 DATA "........GGGGGGGGGGGGGGGG........"
1090 DATA ".......GGGGGGGGGGGGGGGGGG......."
1100 DATA "......GGGGGGGGGGGGGGGGGGGG......"
1110 DATA ".....LLLLLLLLLLLLLLLLLLLLLL....."
1120 DATA "....RRRRRRRRRRRRRRRRRRRRRRRR...."
1130 DATA "....RRRRRRRRRWWWWWWWRRRRRRRR...."
1140 DATA "....RRRRRRRRWYYYYYYYWRRRRRRR...."
1150 DATA "....RRRRRRRRWYYYYYYYWRRRRRRR...."
1160 DATA "....RRRRRRRRRWWWWWWWRRRRRRRR...."
1170 DATA "...LLLLLLLLLLLLLLLLLLLLLLLLLL..."
1180 DATA "..RRRRRRRRRRRRRRRRRRRRRRRRRRRR.."
1190 DATA "..RRRRRRRRRRRRRRRRRRRRRRRRRRRR.."
1200 DATA "..RRRRRRRWWWWWWWWWWWWWWRRRRRRR.."
1210 DATA "..RRRRRRRWOWWWWWWWWWWOWRRRRRRR.."
1220 DATA "..RRRRRRRWOWOWWWWWWOWOWRRRRRRR.."
1230 DATA "..RRRRRRRWWOWOWWWOWOWWWRRRRRRR.."
1240 DATA "..RRRRRRRWWWOWOWOWOWWWWRRRRRRR.."
1250 DATA "..RRRRRRRWWWWOWOWOWWWWWRRRRRRR.."
1260 DATA "..RRRRRRRWWWOWOWOWOWWWWRRRRRRR.."
1270 DATA "..RRRRRRRWWOWOWWWOWOWWWRRRRRRR.."
1280 DATA "..RRRRRRRWOWOWWWWWWOWOWRRRRRRR.."
1290 DATA "..RRRRRRRWOWWWWWWWWWWOWRRRRRRR.."
1300 DATA "..RRRRRRRWWWWWWWWWWWWWWRRRRRRR.."
1310 DATA "..DDDDDDDDDDDDDDDDDDDDDDDDDDDD.."
1400 DATA "................"
1410 DATA "................"
1420 DATA "..M..........M.."
1430 DATA ".MNM........MNM."
1440 DATA ".MNM........MNM."
1450 DATA ".MNMNNNNNNNNMNM."
1460 DATA ".MKMNNNNNNNNMKM."
1470 DATA ".MNM........MNM."
1480 DATA ".MNM........MNM."
1490 DATA ".MNMNNNNNNNNMNM."
1500 DATA ".MKMNNNNNNNNMKM."
1510 DATA ".MNM........MNM."
1520 DATA ".MNM........MNM."
1530 DATA ".MNM........MNM."
1540 DATA ".MMM........MMM."
1550 DATA "................"
1600 DATA "........................"
1610 DATA "..................H....."
1620 DATA ".................HH....."
1630 DATA "................WWWW...."
1640 DATA "...............PWEWP...."
1650 DATA "..............PPPPPP...."
1660 DATA "........BBBBWWWWWW......"
1670 DATA ".......BBBBBBWWWWWWWW..."
1680 DATA "...BBBBBBBBBBWWWWWWWW..."
1690 DATA "..WWBBBBBBBBWWWWWWWWWW.."
1700 DATA ".WWWWWWWWWWWWBBBBWWWWW.."
1710 DATA ".WWWWWWWWWWWWBBBBWWWWW.."
1720 DATA ".WW.WWWWWWWWWWWW.WWWWW.."
1730 DATA "..W...W....W...W..W...W."
1740 DATA "..W...W....U...U..W...W."
1750 DATA "..K...K...........K...K."
1800 DATA "...................."
1810 DATA "...................."
1820 DATA "...............BB..."
1830 DATA ".........WWWW.BBBB.."
1840 DATA ".......WWWWWWWBEEB.."
1850 DATA "......WWGWWWWWWBB..."
1860 DATA ".....WWWWWWWWWW....."
1870 DATA "...WWGWWWWWWGWW....."
1880 DATA "..WWWWWWWWWWWWWW...."
1890 DATA ".WWGWWWWWWGWWWWWW..."
1900 DATA ".WWWWWWWWWWWWWWWW..."
1910 DATA "..WWWWWWWWWWWWWW...."
1920 DATA "...WWGWWGWWWWWW....."
1930 DATA "....B...B...B...B..."
1940 DATA "....B...B...B...B..."
1950 DATA "....K...K...K...K..."
