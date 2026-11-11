@echo off
echo ModSweep troubleshooting mode: error messages are shown in this window.
echo ModSweep Fehlersuche: Fehlermeldungen erscheinen in diesem Fenster.
echo.
powershell.exe -NoProfile -NoExit -ExecutionPolicy Bypass -File "%~dp0ModSweep.ps1"
