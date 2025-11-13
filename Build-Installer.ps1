# Build Script for DW Spectrum Installer
# This creates a standalone executable from the PowerShell script

Write-Host "DW Spectrum Installer Build Tool" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if PS2EXE is installed
$ps2exeInstalled = $false
try {
    $ps2exeCommand = Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue
    if ($ps2exeCommand) {
        $ps2exeInstalled = $true
    }
} catch {
    $ps2exeInstalled = $false
}

if (-not $ps2exeInstalled) {
    Write-Host "PS2EXE module not found. Installing..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
        Write-Host "PS2EXE installed successfully!" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "ERROR: Failed to install PS2EXE module" -ForegroundColor Red
        Write-Host "Please install it manually:" -ForegroundColor Yellow
        Write-Host "  Install-Module -Name ps2exe -Scope CurrentUser" -ForegroundColor White
        Write-Host ""
        pause
        exit
    }
}

# Import the module
Import-Module ps2exe

$scriptPath = Join-Path $PSScriptRoot "DW-Spectrum-Installer.ps1"
$outputPath = Join-Path $PSScriptRoot "DW-Spectrum-Installer.exe"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Source script not found: $scriptPath" -ForegroundColor Red
    pause
    exit
}

Write-Host "Building executable..." -ForegroundColor Yellow
Write-Host "Source: $scriptPath" -ForegroundColor Gray
Write-Host "Output: $outputPath" -ForegroundColor Gray
Write-Host ""

try {
    # Convert PowerShell script to EXE
    Invoke-ps2exe `
        -inputFile $scriptPath `
        -outputFile $outputPath `
        -noConsole `
        -title "DW Spectrum Multi-Monitor Installer" `
        -description "Professional installer for DW Spectrum multi-monitor setup" `
        -company "Your Company Name" `
        -product "DW Spectrum Installer" `
        -copyright "Copyright (c) 2025" `
        -version "1.0.0.0" `
        -requireAdmin `
        -noError `
        -noOutput

    if (Test-Path $outputPath) {
        Write-Host ""
        Write-Host "SUCCESS! Executable created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Output file: $outputPath" -ForegroundColor Cyan
        Write-Host "File size: $([math]::Round((Get-Item $outputPath).Length / 1MB, 2)) MB" -ForegroundColor Gray
        Write-Host ""
        Write-Host "You can now distribute this .exe file to your clients!" -ForegroundColor Green
        Write-Host ""

        $openFolder = Read-Host "Open folder containing the executable? (Y/N)"
        if ($openFolder -eq 'Y' -or $openFolder -eq 'y') {
            explorer.exe "/select,$outputPath"
        }
    } else {
        Write-Host "ERROR: Executable was not created" -ForegroundColor Red
    }

} catch {
    Write-Host "ERROR: Build failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
pause
