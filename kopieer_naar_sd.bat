@echo off
echo ========================================================
echo     Agon Light 2 - Boerderij & Diashow Bestanden Kopi?ren
echo ========================================================

if not exist D:\ (
    echo [!] Schijf D: niet gevonden. Steek de MicroSD-kaart in je PC!
    pause
    exit /b
)

echo Kopi?ren naar MicroSD-kaart (D:)...
copy /Y "C:\agon\boerderij.rgb" "D:\"
copy /Y "C:\agon\molen.rgb" "D:\"
copy /Y "C:\agon\koeien.rgb" "D:\"
copy /Y "C:\agon\trekker.rgb" "D:\"
copy /Y "C:\agon\boerderij_small.rgb" "D:\"
copy /Y "C:\agon\boerderij.plt" "D:\"
copy /Y "C:\agon\tekview.bin" "D:\"
copy /Y "C:\agon\tekview.bin" "D:\bin\" 2>nul
copy /Y "C:\agon\FOTOSHOW.BAS" "D:\"
copy /Y "C:\agon\SNEL.BAS" "D:\"
copy /Y "C:\agon\SNEL24.BAS" "D:\"
copy /Y "C:\agon\FOTO_RGB.BAS" "D:\"
copy /Y "C:\agon\BOERDERIJ.BAS" "D:\"
copy /Y "C:\agon\DEMO.BAS" "D:\"

echo.
echo [V] Alle 4 de foto's en de diashow staan nu op de MicroSD-kaart!
echo Je kunt de kaart nu veilig uitwerpen en in de Agon stoppen.
pause
