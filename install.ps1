#Requires -RunAsAdministrator
<#
.SYNOPSIS
    One-line installer for Windows 11 Niagara Debloat Script
.DESCRIPTION
    Downloads and executes the latest Windows 11 debloat script for Niagara supervisors.
    Usage: irm https://raw.githubusercontent.com/sqrlman-g/niagara-windows11-debloat/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Windows 11 Niagara Debloat - Installer" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check Windows version
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10 -or ($osVersion.Major -eq 10 -and $osVersion.Build -lt 22000)) {
    Write-Host "ERROR: This script requires Windows 11 (Build 22000+)" -ForegroundColor Red
    Write-Host "Your version: $($osVersion.Major).$($osVersion.Minor) (Build $($osVersion.Build))" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "[1/3] Checking system requirements..." -ForegroundColor Yellow
Write-Host "  ✓ Running as Administrator" -ForegroundColor Green
Write-Host "  ✓ Windows 11 detected (Build $($osVersion.Build))" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Downloading latest script..." -ForegroundColor Yellow

$scriptUrl = "https://raw.githubusercontent.com/sqrlman-g/niagara-windows11-debloat/main/windows11-niagara-debloat.ps1"
$downloadPath = "$env:TEMP\windows11-niagara-debloat.ps1"

try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $downloadPath -UseBasicParsing -ErrorAction Stop
    Write-Host "  ✓ Downloaded to: $downloadPath" -ForegroundColor Green
}
catch {
    Write-Host "  ERROR: Failed to download script!" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[3/3] Executing debloat script..." -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Execute the downloaded script
try {
    & $downloadPath
}
catch {
    Write-Host ""
    Write-Host "ERROR: Script execution failed!" -ForegroundColor Red
    Write-Host "$($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Cleanup
try {
    Remove-Item -Path $downloadPath -Force -ErrorAction SilentlyContinue
}
catch {
    # Ignore cleanup errors
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Installation completed!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
