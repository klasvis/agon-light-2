10 REM =========================================================
20 REM       ECHTE AGON BITMAP FOTO: SCHUUR, KOE & SCHAAP        
30 REM =========================================================
40 MODE 8 : CLS
50 PRINT "========================================="
60 PRINT "      ECHTE AGON BITMAP FOTO DEMO        "
70 PRINT "========================================="
80 PRINT
90 PRINT "Laden van boerderij foto in VDP..."
100 H% = OPENIN("boerderij.rgb")
110 IF H% <> 0 THEN CLOSE#H% : PROC_toon_bitmap("boerderij.rgb", 1, 160, 120, 80, 50) ELSE PROC_toon_bitmap("boerderij_small.rgb", 1, 80, 60, 120, 80)
120 PRINT TAB(2, 27); "Foto getoond in echte 64-kleuren Agon Bitmap!"
130 END
140 :
210 DEF PROC_toon_bitmap(bestand$, id%, b%, h%, x%, y%)
220   LOCAL H%, i%, bytes%
230   bytes% = b% * h% * 4
240   H% = OPENIN(bestand$)
250   IF H% = 0 THEN PRINT "Bestand ontbreekt: "; bestand$: ENDPROC
260   PRINT "Laden van "; bestand$; " ("; STR$(b%); "x"; STR$(h%); ")..."
270   REM 1. Selecteer Bitmap ID
280   VDU 23, 27, 0, id%
290   REM 2. Declareer formaat in VDP (b x h RGBA8888)
300   VDU 23, 27, 1, b%; h%;
310   REM 3. Pomp de bytes naar VDP
320   FOR i% = 1 TO bytes%
330     VDU BGET#H%
340   NEXT i%
350   CLOSE#H%
360   REM 4. Teken bitmap gecentreerd op het scherm
370   CLS
380   VDU 23, 27, 0, id%
390   VDU 23, 27, 3, x%; y%;
400 ENDPROC
