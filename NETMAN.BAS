10 REM ==============================================
20 REM        AGON LIGHT 2 - NETWORK MANAGER (NETMAN)
30 REM ==============================================
40 MODE 2
50 CLS
60 PRINT "=============================================="
70 PRINT "      AGON LIGHT 2 - NETWORK MANAGER          "
80 PRINT "=============================================="
90 PRINT
100 PRINT "  1. Verbinden via wifi.txt op SD-kaart"
110 PRINT "  2. Handmatig netwerk en wachtwoord invoeren"
120 PRINT "  3. Zoeken naar WiFi netwerken in de buurt"
130 PRINT "  4. Bekijk huidige verbinding en IP-adres"
140 PRINT "  5. Verbinding verbreken (gegevens wissen)"
150 PRINT "  6. Afsluiten"
160 PRINT
170 INPUT "Maak een keuze (1-6): ", K%
180 IF K% = 1 THEN PROC_connect_file
190 IF K% = 2 THEN PROC_connect_manual
200 IF K% = 3 THEN PROC_scan
210 IF K% = 4 THEN PROC_status
220 IF K% = 5 THEN PROC_disconnect
230 IF K% = 6 THEN CLS: PRINT "Netman afgesloten.": END
240 GOTO 50
250 :
260 DEF PROC_connect_file
270 LOCAL F%, S$, P$
280 F% = OPENIN("wifi.txt")
290 IF F% = 0 THEN PRINT "Fout: wifi.txt niet gevonden op SD kaart!": PROC_wait: ENDPROC
300 S$ = FNreadline(F%)
310 P$ = FNreadline(F%)
320 CLOSE#F%
330 PRINT "Gelezen netwerk: "; S$
340 PROC_send_creds(S$, P$)
350 PROC_wait
360 ENDPROC
370 :
380 DEF PROC_connect_manual
390 LOCAL S$, P$
400 INPUT "Voer netwerknaam (SSID) in: ", S$
410 IF S$ = "" THEN ENDPROC
420 INPUT "Voer wachtwoord in: ", P$
430 PROC_send_creds(S$, P$)
440 PROC_wait
450 ENDPROC
460 :
470 DEF PROC_send_creds(S$, P$)
480 LOCAL I%
490 PRINT "Versturen naar ESP32..."
500 VDU 23, 0, &F1, 0
510 FOR I%=1 TO LEN(S$): VDU ASC(MID$(S$, I%, 1)): NEXT I%
520 VDU 0
530 FOR I%=1 TO LEN(P$): VDU ASC(MID$(P$, I%, 1)): NEXT I%
540 VDU 0
550 PRINT "Gegevens verzonden! De ESP32 verbindt nu..."
560 ENDPROC
570 :
580 DEF PROC_scan
590 PRINT "Scannen naar netwerken..."
600 VDU 23, 0, &F1, 3
610 PROC_wait
620 ENDPROC
630 :
640 DEF PROC_status
650 VDU 23, 0, &F1, 2
660 PROC_wait
670 ENDPROC
680 :
690 DEF PROC_disconnect
700 VDU 23, 0, &F1, 1
710 PRINT "WiFi verbroken en gegevens gewist."
720 PROC_wait
730 ENDPROC
740 :
750 DEF PROC_wait
760 PRINT
770 PRINT "Druk op een toets om terug te keren naar het menu..."
780 K$ = GET$
790 ENDPROC
800 :
810 DEF FNreadline(H%)
820 LOCAL R$, B%
830 R$ = ""
840 REPEAT
850   IF EOF#H% THEN = R$
860   B% = BGET#H%
870   IF B% >= 32 AND B% <= 126 THEN R$ = R$ + CHR$(B%)
880 UNTIL B% = 10 OR (B% = 13 AND LEN(R$) > 0)
890 = R$
