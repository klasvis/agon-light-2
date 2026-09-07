10 MODE 8
20 VDU 23,1,0: REM Verberg cursor
30 CLS
40 COLOUR 11
50 PRINT TAB(6,2); "=== AGON LIGHT 2 - GAMES MENU ==="
60 COLOUR 15
70 PRINT TAB(4,5);  "[1] Munchman (Pac-Man)"
80 PRINT TAB(4,6);  "[2] Cosmic Invaders"
90 PRINT TAB(4,7);  "[3] Snac-Snake"
100 PRINT TAB(4,8);  "[4] Lunar Lander"
110 PRINT TAB(4,9);  "[5] Grand Prix Race"
120 PRINT TAB(4,10); "[6] Nomis (Simon Says)"
130 PRINT TAB(4,11); "[7] 3D Maze (Labyrint)"
140 PRINT TAB(4,12); "[8] Minefield (Mijnenveger)"
150 PRINT TAB(4,13); "[9] Super Boerderij"
160 PRINT TAB(4,14); "[A] Hunt the Wumpus"
170 PRINT TAB(4,15); "[B] Super Star Trek"
180 PRINT TAB(4,16); "[C] Enchanted Castle"
190 PRINT TAB(4,17); "[D] Nim"
200 PRINT TAB(4,18); "[E] Pitman"
210 COLOUR 14
220 PRINT TAB(4,20); "[Q] Terug naar BASIC prompt"
230 COLOUR 10
240 PRINT TAB(4,22); "Maak je keuze: ";
250 K$ = GET$
260 IF K$="1" THEN CHAIN "games/munchman.bas"
270 IF K$="2" THEN CHAIN "games/invaders.bas"
280 IF K$="3" THEN CHAIN "games/snake.bas"
290 IF K$="4" THEN CHAIN "games/lander.bas"
300 IF K$="5" THEN CHAIN "games/grandprix.bas"
310 IF K$="6" THEN CHAIN "games/nomis.bas"
320 IF K$="7" THEN CHAIN "games/3dmaze.bas"
330 IF K$="8" THEN CHAIN "games/minefield.bas"
340 IF K$="9" THEN CHAIN "SUPER_BOERDERIJ.BAS"
350 IF K$="A" OR K$="a" THEN CHAIN "games/wumpus.bas"
360 IF K$="B" OR K$="b" THEN CHAIN "games/startrek.bas"
370 IF K$="C" OR K$="c" THEN CHAIN "games/enchanted.bas"
380 IF K$="D" OR K$="d" THEN CHAIN "games/nim.bas"
390 IF K$="E" OR K$="e" THEN CHAIN "pitman.bas"
400 IF K$="Q" OR K$="q" THEN VDU 23,1,1: MODE 0: END
410 GOTO 250
