@echo off
title Agon Light 2 - Virtual Color Monitor (Wi-Fi AP)
cd /d C:\agon
echo ============================================================
echo  Agon Light 2 - Draadloze Virtuele Monitor via Wi-Fi AP
echo ============================================================
echo  1. Zorg dat je PC/laptop verbonden is met Wi-Fi: Agon-Light-VDP
echo  2. Verbinden met 192.168.4.1 op poort 23...
echo ============================================================
python agon_monitor.py --wifi 192.168.4.1:23
pause
