@echo off
title Flurt - Movie Web App (Port 3000)
echo ========================================================
echo   FLURT - FLUTTER WEB MOVIE STREAMING APP
echo ========================================================
echo   Running on: http://localhost:3000
echo ========================================================
echo.
cd /d "%~dp0frontend"
if exist "H:\flutter\bin\flutter.bat" (
    "H:\flutter\bin\flutter.bat" run -d chrome --web-port 3000
) else (
    flutter run -d chrome --web-port 3000
)
pause
