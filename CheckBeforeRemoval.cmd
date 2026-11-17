@echo off
if "%~1"=="" (
 echo Drag the patched game executable onto this file before removal.
 pause
 exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0CheckCompatibility.ps1" -ExePath "%~1" -Mode Remove
pause
