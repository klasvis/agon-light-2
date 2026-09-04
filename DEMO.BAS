10 REM =========================================================
20 REM           AGON EXPEDITIE: RETRO VECTOR AVONTUUR          
30 REM =========================================================
40 MODE 0 : CLS
50 PRINT "========================================================="
60 PRINT "      DE AGON EXPEDITIE: EEN RETRO VECTOR AVONTUUR       "
70 PRINT "========================================================="
80 PRINT
90 PRINT "Welkom bij de Agon Adventure Demo!"
100 PRINT "Dit spel toont hoe je vector-illustraties (.plt),"
110 PRINT "zoals 'voorbeeld.plt' (gemaakt van een JPG),"
120 PRINT "direct in BBC BASIC integreert voor sfeervolle kamers."
130 PRINT
140 PRINT "Druk op een toets om de expeditie te starten..."
150 K$ = GET$
160 :
170 REM --- Spelvariabelen ---
180 kamer% = 1
190 oude_kamer% = 0
200 heeft_dongle% = 0
210 heeft_tape% = 0
220 :
230 REM --- Hoofdlus van het spel ---
240 REPEAT
250   IF kamer% <> oude_kamer% THEN PROC_toon_kamer(kamer%) : oude_kamer% = kamer%
260   PRINT
270   PRINT "---------------------------------------------------------"
280   PRINT "Keuzes: [N]oord, [O]ost, [Z]uid, [W]est, [P]ak, [K]ijk, [Q]uit"
290   PRINT "Wat doe je? ";
300   K$ = GET$ : PRINT K$
310   PRINT
320   IF K$ = "q" OR K$ = "Q" THEN GOTO 500
330   IF K$ = "k" OR K$ = "K" THEN PROC_kijk
340   IF (K$ = "p" OR K$ = "P") AND kamer% = 1 AND heeft_tape% = 0 THEN PRINT "Je pakt de zware datacassette van de console!" : heeft_tape% = 1 : PROC_wacht
350   IF (K$ = "p" OR K$ = "P") AND kamer% = 2 AND heeft_dongle% = 0 THEN PRINT "Je pakt de UEXT-dongle op en steekt hem in je zak!" : heeft_dongle% = 1 : PROC_wacht
360   PROC_beweeg(K$)
370 UNTIL FALSE
380 :
500 CLS
510 PRINT "Bedankt voor het spelen van de Agon Expeditie!"
520 END
530 :
540 REM --- Toon kamer ---
550 DEF PROC_toon_kamer(k%)
560   IF k% = 1 THEN PROC_kamer1
570   IF k% = 2 THEN PROC_kamer2
580   IF k% = 3 THEN PROC_kamer3
590   IF k% = 4 THEN PROC_kamer4
600 ENDPROC
610 :
620 REM --- Kamer 1: De Brug ---
630 DEF PROC_kamer1
640   PROC_toon_vector("starship.plt")
650   PRINT "=== DE COMMANDOBRUG (USS ENTERPRISE) ==="
660   PRINT "Je staat op de brug van het sterrenschip."
670   PRINT "Monitors flikkeren in groen fosfor."
680   IF heeft_tape% = 0 THEN PRINT ">> Er ligt een [DATACASSETTE] op de console! (Druk P)"
690   PRINT "Uitgangen: [O]ost naar het Hardware Lab, [Z]uid naar de Lounge."
700 ENDPROC
710 :
720 REM --- Kamer 2: Het Agon Lab ---
730 DEF PROC_kamer2
740   PROC_toon_vector("voorbeeld.plt")
750   PRINT "=== HET AGON LIGHT 2 HARDWARE LAB ==="
760   PRINT "Overal staan oscilloscopen en soldeerstations."
770   PRINT "Centraal ligt een Agon Light 2 bordje (voorbeeld.plt)!"
780   IF heeft_dongle% = 0 THEN PRINT ">> Naast het bordje ligt een [UEXT-DONGLE]! (Druk P)"
790   PRINT "Uitgangen: [W]est naar de Brug, [Z]uid naar de Koepel."
800 ENDPROC
810 :
820 REM --- Kamer 3: De Lounge ---
830 DEF PROC_kamer3
840   PROC_toon_vector("snoopy.plt")
850   PRINT "=== DE ASTRONAUTEN LOUNGE ==="
860   PRINT "Een knusse ontspanningsruimte voor de bemanning."
870   PRINT "Aan de stalen wand hangt een retro Snoopy-poster."
880   PRINT "Uitgangen: [N]oord naar de Brug, [O]ost naar de Koepel."
890 ENDPROC
900 :
910 REM --- Kamer 4: De Navigatiekoepel ---
920 DEF PROC_kamer4
930   PROC_toon_vector("gplanet.plt")
940   PRINT "=== DE NAVIGATIEKOEPEL ==="
950   PRINT "Door het glazen koepeldak zie je een 3D vector-planeet draaien."
960   IF heeft_dongle% = 1 AND heeft_tape% = 1 THEN PROC_gewonnen
970   PRINT "Uitgangen: [N]oord naar het Lab, [W]est naar de Lounge."
980 ENDPROC
990 :
1000 DEF PROC_gewonnen
1010  PRINT "*********************************************************"
1020  PRINT "*** MISSIE GESLAAGD! JE HEBT GEWONNEN!                ***"
1030  PRINT "Met de UEXT-dongle en datacassette activeer je het"
1040  PRINT "subruimte-relais van het Agon netwerk!"
1050  PRINT "*********************************************************"
1060 ENDPROC
1070 :
1080 REM --- Vector loader ---
1090 DEF PROC_toon_vector(bestandsnaam$)
1100  LOCAL H%, B%
1110  H% = OPENIN(bestandsnaam$)
1120  IF H% = 0 THEN CLS : PRINT "(Illustratie ontbreekt: "; bestandsnaam$; ")": ENDPROC
1130  VDU 23, 0, &FC, 2
1140  REPEAT
1150    B% = BGET#H%
1160    VDU B%
1170  UNTIL EOF#H%
1180  CLOSE#H%
1190  VDU 23, 0, &FC, 0
1200 ENDPROC
1210 :
1220 REM --- Bewegingslogica ---
1230 DEF PROC_beweeg(R$)
1240  LOCAL r$
1250  r$ = R$
1260  IF (r$ = "o" OR r$ = "O") AND kamer% = 1 THEN kamer% = 2 : ENDPROC
1270  IF (r$ = "o" OR r$ = "O") AND kamer% = 3 THEN kamer% = 4 : ENDPROC
1280  IF (r$ = "w" OR r$ = "W") AND kamer% = 2 THEN kamer% = 1 : ENDPROC
1290  IF (r$ = "w" OR r$ = "W") AND kamer% = 4 THEN kamer% = 3 : ENDPROC
1300  IF (r$ = "z" OR r$ = "Z") AND kamer% = 1 THEN kamer% = 3 : ENDPROC
1310  IF (r$ = "z" OR r$ = "Z") AND kamer% = 2 THEN kamer% = 4 : ENDPROC
1320  IF (r$ = "n" OR r$ = "N") AND kamer% = 3 THEN kamer% = 1 : ENDPROC
1330  IF (r$ = "n" OR r$ = "N") AND kamer% = 4 THEN kamer% = 2 : ENDPROC
1340  IF r$ = "k" OR r$ = "K" OR r$ = "p" OR r$ = "P" THEN ENDPROC
1350  PRINT "Die kant kun je niet op!"
1360  PROC_wacht
1370 ENDPROC
1380 :
1390 DEF PROC_kijk
1400  PRINT "Je inspecteert je uitrusting:"
1410  IF heeft_dongle% = 1 THEN PRINT "- [UEXT-dongle] zit veilig in je jaszak."
1420  IF heeft_tape% = 1 THEN PRINT "- [Datacassette] onder je arm geklemd."
1430  IF heeft_dongle% = 0 AND heeft_tape% = 0 THEN PRINT "- Je zakken zijn momenteel leeg."
1440  PROC_wacht
1450 ENDPROC
1460 :
1470 DEF PROC_wacht
1480  PRINT "Druk op een toets om door te gaan..."
1490  K$ = GET$
1500 ENDPROC
