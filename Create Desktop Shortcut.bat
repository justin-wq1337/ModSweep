@echo off
set "MSDIR=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$dir=$env:MSDIR; $d=[Environment]::GetFolderPath('Desktop'); $s=(New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $d 'ModSweep for The Sims 4.lnk')); $s.TargetPath=(Join-Path $env:SystemRoot 'System32\conhost.exe'); $s.Arguments='powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"' + (Join-Path $dir 'ModSweep.ps1') + '\"'; $s.WorkingDirectory=$dir; $s.IconLocation=(Join-Path $dir 'icon.ico'); $s.WindowStyle=7; $s.Description='ModSweep for The Sims 4'; $s.Save()"
echo.
echo Done: "ModSweep for The Sims 4" is now on your desktop.
echo Fertig: "ModSweep for The Sims 4" liegt jetzt auf deinem Desktop.
echo.
pause
