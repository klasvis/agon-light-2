@echo off
if "%~1"=="" (
    echo ========================================================
    echo      JPG / PNG naar Tektronix PLT Vector Converter
    echo ========================================================
    echo Gebruik:
    echo   Sleep een JPG of PNG afbeelding op dit bestand!
    echo   Of typ in de command line:
    echo     converteer_naar_plt.bat afbeelding.jpg [uitvoer.plt]
    echo.
    set /p INP="Of typ hier het pad naar je afbeelding: "
) else (
    set INP=%~1
)

if "%INP%"=="" goto end

python "C:\agon\convert_jpg_to_plt.py" "%INP%" "%~dpn1.plt"

echo.
echo Klaar! Het bestand is opgeslagen als: "%~dpn1.plt"
pause
:end
