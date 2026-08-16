@echo off
title Flurt - Watch Party WebSocket Server (Port 8080)
echo ========================================================
echo   FLURT WATCH PARTY - BACKEND WEBSOCKET SERVER
echo ========================================================
echo   REST API:   http://localhost:8080
echo   WebSocket:  ws://localhost:8080/ws/party
echo ========================================================
echo.
cd /d "%~dp0backend"
if exist "H:\flutter\bin\cache\dart-sdk\bin\dart.exe" (
    "H:\flutter\bin\cache\dart-sdk\bin\dart.exe" run bin/server.dart
) else (
    dart run bin/server.dart
)
pause
