10 REM =========================================================
20 REM       DE GROTE AGON BOERDERIJ: GRAPHICS & SPRITES DEMO   
30 REM =========================================================
40 MODE 8 : CLS
50 VDU 23, 1, 0 : REM Verberg tekstcursor
60 PROC_landschap
70 PRINT TAB(2,1); "Bitmaps laden in VDP videogeheugen...";
80 PROC_maak_trekker(1)
90 PROC_maak_koe(2)
100 PROC_maak_schaap(3)
110 PROC_maak_varken(4)
120 PROC_maak_boom(5)
130 PROC_maak_tulp(6)
140 PROC_plaats_erf
150 PROC_banners
160 PROC_trekkerrit
170 VDU 23, 1, 1 : REM Herstel cursor
180 CLS : PRINT "Bedankt voor het bezoeken van de Agon Boerderij!"
190 END
500 REM =========================================================
510 REM LANDSCHAP TEKENEN
520 REM =========================================================
530 DEF PROC_landschap
540   GCOL 0, 9
550   MOVE 0, 500 : PLOT 101, 1279, 959 : REM Hemelsblauwe lucht
560   GCOL 0, 3
570   MOVE 1050, 800 : PLOT 157, 1120, 800 : REM Gele Zon
580   MOVE 1050, 880 : PLOT 5, 1050, 930
590   MOVE 1050, 720 : PLOT 5, 1050, 670
600   MOVE 970, 800  : PLOT 5, 920, 800
610   MOVE 1130, 800 : PLOT 5, 1180, 800
620   MOVE 990, 860  : PLOT 5, 950, 900
630   MOVE 1110, 860 : PLOT 5, 1150, 900
640   MOVE 990, 740  : PLOT 5, 950, 700
650   MOVE 1110, 740 : PLOT 5, 1150, 700
660   GCOL 0, 15
670   PROC_wolk(180, 840)
680   PROC_wolk(560, 810)
690   PROC_wolk(880, 860)
700   GCOL 0, 2
710   MOVE 0, 0 : PLOT 101, 1279, 520 : REM Groene weide
720   GCOL 0, 10
730   MOVE 0, 480 : MOVE 700, 480 : MOVE 350, 550 : PLOT 197, 0, 0 : REM Heuvels
740   GCOL 0, 4
750   MOVE 880, 260 : MOVE 1080, 260 : MOVE 880, 360 : PLOT 197, 0, 0 : REM Vijver
760   GCOL 0, 10
770   MOVE 800, 280 : PLOT 157, 815, 280 : REM Waterlelies
780   MOVE 880, 320 : PLOT 157, 898, 320
790   MOVE 960, 240 : PLOT 157, 975, 240
800   GCOL 0, 11
810   MOVE 230, 480 : MOVE 290, 480 : PLOT 85, 420, 260 : REM Zandpad
820   MOVE 230, 480 : MOVE 420, 260 : PLOT 85, 330, 260
830   MOVE 330, 260 : MOVE 420, 260 : PLOT 85, 600, 0
840   MOVE 330, 260 : MOVE 600, 0   : PLOT 85, 450, 0
850   GCOL 0, 1 : REM Rode Boerderijschuur
860   MOVE 90, 430 : PLOT 101, 410, 660
870   GCOL 0, 12 : REM Pannen dak
880   MOVE 70, 660 : MOVE 430, 660 : PLOT 85, 250, 830
890   GCOL 0, 0
900   MOVE 250, 750 : PLOT 157, 275, 750 : REM Zolderraam
910   GCOL 0, 15
920   MOVE 250, 750 : PLOT 157, 270, 750
930   GCOL 0, 8 : REM Houten staldeuren
940   MOVE 205, 430 : PLOT 101, 295, 570
950   GCOL 0, 0
960   MOVE 205, 430 : PLOT 5, 295, 570
970   MOVE 205, 570 : PLOT 5, 295, 430
980   MOVE 250, 430 : PLOT 5, 250, 570
990   GCOL 0, 15 : REM Ramen
1000   MOVE 125, 510 : PLOT 101, 175, 580
1010   MOVE 325, 510 : PLOT 101, 375, 580
1020   GCOL 0, 0
1030   MOVE 150, 510 : PLOT 5, 150, 580
1040   MOVE 125, 545 : PLOT 5, 175, 545
1050   MOVE 350, 510 : PLOT 5, 350, 580
1060   MOVE 325, 545 : PLOT 5, 375, 545
1070   GCOL 0, 15 : REM Windmolen
1080   MOVE 560, 480 : MOVE 670, 480 : PLOT 85, 650, 720
1090   MOVE 560, 480 : MOVE 650, 720 : PLOT 85, 580, 720
1100   GCOL 0, 2
1110   MOVE 570, 720 : MOVE 660, 720 : PLOT 85, 615, 770
1120   GCOL 0, 15 : REM Wieken
1130   MOVE 615, 745 : PLOT 5, 525, 655
1140   MOVE 615, 745 : PLOT 5, 705, 835
1150   MOVE 615, 745 : PLOT 5, 525, 835
1160   MOVE 615, 745 : PLOT 5, 705, 655
1170   GCOL 0, 0 : MOVE 615, 745 : PLOT 157, 621, 745
1180   GCOL 0, 3 : REM Hekwerk
1190   MOVE 440, 460 : PLOT 5, 750, 460
1200   MOVE 440, 480 : PLOT 5, 750, 480
1210   FOR px% = 440 TO 750 STEP 30
1220     MOVE px%, 445 : PLOT 5, px%, 500
1230   NEXT px%
1240 ENDPROC
1300 DEF PROC_wolk(wx%, wy%)
1310   MOVE wx%, wy%       : PLOT 157, wx%+30, wy%
1320   MOVE wx%+35, wy%+10 : PLOT 157, wx%+75, wy%+10
1330   MOVE wx%+70, wy%    : PLOT 157, wx%+95, wy%
1340   MOVE wx%-15, wy%-10 : PLOT 101, wx%+85, wy%+10
1350 ENDPROC
1500 REM =========================================================
1510 REM BITMAPS AANMAKEN
1520 REM =========================================================
1530 DEF PROC_maak_trekker(id%)
1540   LOCAL Y%, X%, r$, c$
1550   RESTORE 4000
1560   VDU 23, 27, 0, id% : VDU 23, 27, 1, 24; 16;
1570   FOR Y%=1 TO 16 : READ r$
1580     FOR X%=1 TO 24 : c$ = MID$(r$, X%, 1)
1590       IF c$ = "R" THEN VDU 230, 35, 35, 255
1600       IF c$ = "D" THEN VDU 150, 20, 20, 255
1610       IF c$ = "Y" THEN VDU 255, 220, 20, 255
1620       IF c$ = "G" THEN VDU 130, 135, 140, 255
1630       IF c$ = "S" THEN VDU 45, 50, 55, 255
1640       IF c$ = "K" THEN VDU 20, 20, 22, 255
1650       IF c$ = "." THEN VDU 0, 0, 0, 0
1660     NEXT X%
1670   NEXT Y%
1680 ENDPROC
1700 DEF PROC_maak_koe(id%)
1710   LOCAL Y%, X%, r$, c$
1720   RESTORE 4200
1730   VDU 23, 27, 0, id% : VDU 23, 27, 1, 24; 16;
1740   FOR Y%=1 TO 16 : READ r$
1750     FOR X%=1 TO 24 : c$ = MID$(r$, X%, 1)
1760       IF c$ = "W" THEN VDU 250, 250, 250, 255
1770       IF c$ = "B" THEN VDU 25, 25, 30, 255
1780       IF c$ = "P" THEN VDU 255, 175, 185, 255
1790       IF c$ = "Y" THEN VDU 235, 205, 130, 255
1800       IF c$ = "H" THEN VDU 60, 60, 65, 255
1810       IF c$ = "." THEN VDU 0, 0, 0, 0
1820     NEXT X%
1830   NEXT Y%
1840 ENDPROC
1900 DEF PROC_maak_schaap(id%)
1910   LOCAL Y%, X%, r$, c$
1920   RESTORE 4400
1930   VDU 23, 27, 0, id% : VDU 23, 27, 1, 16; 16;
1940   FOR Y%=1 TO 16 : READ r$
1950     FOR X%=1 TO 16 : c$ = MID$(r$, X%, 1)
1960       IF c$ = "W" THEN VDU 255, 255, 255, 255
1970       IF c$ = "G" THEN VDU 210, 215, 220, 255
1980       IF c$ = "B" THEN VDU 30, 30, 35, 255
1990       IF c$ = "." THEN VDU 0, 0, 0, 0
2000     NEXT X%
2010   NEXT Y%
2020 ENDPROC
2100 DEF PROC_maak_varken(id%)
2110   LOCAL Y%, X%, r$, c$
2120   RESTORE 4600
2130   VDU 23, 27, 0, id% : VDU 23, 27, 1, 16; 16;
2140   FOR Y%=1 TO 16 : READ r$
2150     FOR X%=1 TO 16 : c$ = MID$(r$, X%, 1)
2160       IF c$ = "P" THEN VDU 255, 175, 190, 255
2170       IF c$ = "D" THEN VDU 220, 100, 135, 255
2180       IF c$ = "B" THEN VDU 30, 30, 35, 255
2190       IF c$ = "." THEN VDU 0, 0, 0, 0
2200     NEXT X%
2210   NEXT Y%
2220 ENDPROC
2300 DEF PROC_maak_boom(id%)
2310   LOCAL Y%, X%, r$, c$
2320   RESTORE 4800
2330   VDU 23, 27, 0, id% : VDU 23, 27, 1, 16; 20;
2340   FOR Y%=1 TO 20 : READ r$
2350     FOR X%=1 TO 16 : c$ = MID$(r$, X%, 1)
2360       IF c$ = "G" THEN VDU 35, 140, 35, 255
2370       IF c$ = "L" THEN VDU 65, 190, 55, 255
2380       IF c$ = "R" THEN VDU 235, 30, 30, 255
2390       IF c$ = "B" THEN VDU 110, 60, 25, 255
2400       IF c$ = "D" THEN VDU 75, 35, 15, 255
2410       IF c$ = "." THEN VDU 0, 0, 0, 0
2420     NEXT X%
2430   NEXT Y%
2440 ENDPROC
2500 DEF PROC_maak_tulp(id%)
2510   LOCAL Y%, X%, r$, c$
2520   RESTORE 5000
2530   VDU 23, 27, 0, id% : VDU 23, 27, 1, 8; 12;
2540   FOR Y%=1 TO 12 : READ r$
2550     FOR X%=1 TO 8 : c$ = MID$(r$, X%, 1)
2560       IF c$ = "R" THEN VDU 240, 25, 25, 255
2570       IF c$ = "Y" THEN VDU 255, 215, 0, 255
2580       IF c$ = "G" THEN VDU 35, 160, 35, 255
2590       IF c$ = "." THEN VDU 0, 0, 0, 0
2600     NEXT X%
2610   NEXT Y%
2620 ENDPROC
2700 REM =========================================================
2710 REM PLAATSEN OP HET ERF
2720 REM =========================================================
2730 DEF PROC_plaats_erf
2740   VDU 23, 27, 0, 5 : REM Appelboompjes
2750   VDU 23, 27, 3, 10; 125;
2760   VDU 23, 27, 3, 28; 155;
2770   VDU 23, 27, 3, 8; 185;
2780   VDU 23, 27, 0, 6 : REM Tulpen
2790   FOR tx% = 35 TO 95 STEP 10
2800     VDU 23, 27, 3, tx%; 110;
2810   NEXT tx%
2820   VDU 23, 27, 0, 3 : REM Schapen
2830   VDU 23, 27, 3, 115; 108;
2840   VDU 23, 27, 3, 155; 112;
2850   VDU 23, 27, 3, 180; 118;
2860   VDU 23, 27, 0, 2 : REM Koeien
2870   VDU 23, 27, 3, 130; 135;
2880   VDU 23, 27, 3, 168; 155;
2890   VDU 23, 27, 0, 4 : REM Varkens
2900   VDU 23, 27, 3, 198; 185;
2910   VDU 23, 27, 3, 230; 195;
2920   VDU 23, 27, 0, 1 : REM Trekker start
2930   VDU 23, 27, 3, 90; 170;
2940 ENDPROC
3000 REM =========================================================
3010 REM BANNERS & INSTRUCTIES
3020 REM =========================================================
3030 DEF PROC_banners
3040   COLOUR 15
3050   PRINT TAB(2,0); "=== DE GROTE AGON BOERDERIJ ===";
3060   PRINT TAB(2,1); "Trekker, Koeien, Schapen, Varkens & Molen!";
3070   COLOUR 10
3080   PRINT TAB(1,28); "[PIJLTJES/WASD]=Rijden | [SPATIE]=Toeter | [ESC]=Stop";
3090 ENDPROC
3200 REM =========================================================
3210 REM INTERACTIEVE TREKKERRIT
3220 REM =========================================================
3230 DEF PROC_trekkerrit
3240   LOCAL TX%, TY%, K%, OX%, OY%
3250   TX% = 90 : TY% = 170
3260   REPEAT
3270     K% = INKEY(2)
3280     IF K% = 27 THEN ENDPROC
3290     IF K% = 32 THEN SOUND 1, -15, 120, 3 : SOUND 1, -15, 140, 4
3300     OX% = TX% : OY% = TY%
3310     IF (K% = 21 OR K% = 68 OR K% = 100) AND TX% < 290 THEN TX% = TX% + 3
3320     IF (K% = 8  OR K% = 65 OR K% = 97)  AND TX% > 10  THEN TX% = TX% - 3
3330     IF (K% = 11 OR K% = 87 OR K% = 119) AND TY% > 130 THEN TY% = TY% - 2
3340     IF (K% = 10 OR K% = 83 OR K% = 115) AND TY% < 218 THEN TY% = TY% + 2
3350     IF OX% <> TX% OR OY% <> TY% THEN PROC_verplaats(OX%, OY%, TX%, TY%)
3360   UNTIL FALSE
3370 ENDPROC
3380 :
3390 DEF PROC_verplaats(ox%, oy%, tx%, ty%)
3400   GCOL 0, 11
3410   MOVE ox%*4, (239-oy%-16)*4
3420   PLOT 101, (ox%+24)*4, (239-oy%)*4
3430   VDU 23, 27, 0, 1
3440   VDU 23, 27, 3, tx%; ty%;
3450 ENDPROC
3990 REM =========================================================
3995 REM SPRITE DATA
3999 REM =========================================================
4000 DATA ".......S................"
4010 DATA "......SS................"
4020 DATA ".......S.........G......"
4030 DATA ".......S........G......."
4040 DATA ".......S.......GG......."
4050 DATA "..RRRRRRRRRRRRRRR......."
4060 DATA "..RRRRRRRRRRRRRRRR......"
4070 DATA "Y.RRRRRRRRRRRRRRRRD....."
4080 DATA "..GGGGGGGGGG.KKKKKKK...."
4090 DATA "..GGGGGGGGGGKKKKKKKKK..."
4100 DATA "...KKKK....KKKYYYYYKKK.."
4110 DATA "..KKYYKK...KKYYYYYYYKK.."
4120 DATA "..KKYYKK...KKYYYYYYYKK.."
4130 DATA "...KKKK....KKKYYYYYKKK.."
4140 DATA "............KKKKKKKKK..."
4150 DATA ".............KKKKKKK...."
4200 DATA "..Y...Y................."
4210 DATA ".WWWWWWW................"
4220 DATA ".WBWWBWW................"
4230 DATA ".PPPPPPP.WWWWWWWWWWWW..."
4240 DATA "..PPPPP.WWBWWWWBBBWWWW.."
4250 DATA "...WW..WWBBWWWWBBBBWWWW."
4260 DATA ".......WWBBBWWWWBBBWWWW."
4270 DATA ".......WWWWWWWWWWWWWWWW."
4280 DATA ".......WWWWWWWWWWWWWWWW."
4290 DATA ".......WWWWWWWWWWWPPPW.."
4300 DATA ".......WWWWWWWWWWWPPP..."
4310 DATA "........WW..WW..WW..WW.."
4320 DATA "........WW..WW..WW..WW.."
4330 DATA "........BB..WW..BB..WW.."
4340 DATA "........HH..HH..HH..HH.."
4350 DATA "........................"
4400 DATA "......WWWW......"
4410 DATA "....WWWWWWWW...."
4420 DATA "...WWGWWWWGGW..."
4430 DATA ".BB.WWWWWWWWWW.."
4440 DATA "BBBW.WWGGWWWWWW."
4450 DATA ".BB.WWWWWWWWWWG."
4460 DATA "....WWGWWWWGGWW."
4470 DATA "....WWWWWWWWWW.."
4480 DATA "....WWGWWWWGGW.."
4490 DATA ".....WWWWWWWW..."
4500 DATA "......WWWWWW...."
4510 DATA "......B....B...."
4520 DATA "......B....B...."
4530 DATA "......B....B...."
4540 DATA "......B....B...."
4550 DATA "................"
4600 DATA "...D............"
4610 DATA "..DDD..........."
4620 DATA ".DPPPP..PPPPP..."
4630 DATA "DPPBPP.PPPPPPP.."
4640 DATA "DDDDDPPPPPPPPP.."
4650 DATA "DDDDDPPPPPPPPP.."
4660 DATA ".DPPPPPPPPPPPPP."
4670 DATA "..PPPPPPPPPPPPPD"
4680 DATA "..PPPPPPPPPPPP.D"
4690 DATA "..PPPPPPPPPPPD.D"
4700 DATA "...PPPPPPPP...DD"
4710 DATA "....PPPPPP......"
4720 DATA "....P..P..P..P.."
4730 DATA "....P..P..P..P.."
4740 DATA "....B..B..B..B.."
4750 DATA "................"
4800 DATA ".....LLLLL......"
4810 DATA "...LLLLLLLLL...."
4820 DATA "..LLGLLLLLGLL..."
4830 DATA ".LLGGRGLLGGRLL.."
4840 DATA ".LGGGGLLGGGGLL.."
4850 DATA "GGGGGGGGGGGGGGG."
4860 DATA "GGGRGGGGGRGGGGG."
4870 DATA "GGGGGGGGGGGGGGG."
4880 DATA "GGGGGGGGGRGGGGG."
4890 DATA ".GGGGGRGGGGGGG.."
4900 DATA "..GGGGGGGGGGG..."
4910 DATA "...GGGGGGGGG...."
4920 DATA ".....GGGGG......"
4930 DATA "......BBB......."
4940 DATA "......BDB......."
4950 DATA "......BDB......."
4960 DATA "......BDB......."
4970 DATA "......BDB......."
4980 DATA ".....BBDBB......"
4990 DATA "....BBBDDBB....."
5000 DATA ".R.R.R.."
5010 DATA ".RRRRR.."
5020 DATA ".RRRRR.."
5030 DATA "..RRR..."
5040 DATA "...G...."
5050 DATA "..GGG..."
5060 DATA ".G.G...."
5070 DATA "...G.G.."
5080 DATA "...GGG.."
5090 DATA "...G...."
5100 DATA "...G...."
5110 DATA "...G...."
