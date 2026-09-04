@echo off
if "%~1"=="" (
    echo ========================================================
    echo      JPG / PNG naar Agon Bitmap (.RGB) Converter
    echo ========================================================
    echo Gebruik:
    echo   Sleep een JPG of PNG afbeelding op dit bestand!
    echo   Standaard wordt de foto geschaald naar 160x120 pixels.
    echo.
    set /p INP="Of typ hier het pad naar je afbeelding: "
) else (
    set INP=%~1
)

if "%INP%"=="" goto end

python "C:\agon\convert_jpg_to_bitmap.py" "%INP%" 160 120 "%~dpn1.rgb"

echo.
echo Klaar! Het bestand is opgeslagen als: "%~dpn1.rgb"
echo (160x120 pixels, RGBA8888 formaat voor de Agon VDP)
pause
:end
