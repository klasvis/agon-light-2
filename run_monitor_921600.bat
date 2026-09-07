@echo off
title Agon Light 2 - Virtual Color Monitor (921600 baud)
cd /d C:\agon
python agon_monitor.py --baud 921600 %*
pause
