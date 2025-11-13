@echo off
REM DW Spectrum Multi-Monitor Launcher
REM Double-click this file to launch DW Spectrum on all monitors

echo Starting DW Spectrum Multi-Monitor Setup...
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0Launch-DWSpectrum.ps1"

if errorlevel 1 (
    echo.
    echo An error occurred. Press any key to exit...
    pause >nul
)
