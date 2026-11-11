@echo off
rem conhost is used so the console window stays hidden, also with Windows Terminal
start "" "%SystemRoot%\System32\conhost.exe" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0ModSweep.ps1"
