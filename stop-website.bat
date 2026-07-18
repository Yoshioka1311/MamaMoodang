@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\stop-website.ps1"
if errorlevel 1 pause
