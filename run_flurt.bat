@echo off
title Flurt - Launcher
echo ========================================================
echo   STARTING FLURT FULL-STACK MOVIE & WATCH PARTY APP
echo ========================================================
echo.
start "Flurt Backend Server (8080)" cmd /k "%~dp0run_backend.bat"
timeout /t 2 /nobreak >nul
start "Flurt Frontend Web (3000)" cmd /k "%~dp0run_frontend.bat"
echo All services launched!
