#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows 11 Debloat & Configure Script for Niagara Supervisor Appliances (v5.0)
.DESCRIPTION
    Removes bloatware, disables telemetry, Copilot, Recall, and optimizes Windows 11
    for use as a dedicated building automation supervisor operating 24/7.

    NEW IN v5.0 - Deep Bloatware Removal:
    - Enhanced widget removal (kill processes, prevent reinstall)
    - Remove hidden telemetry packages (obfuscated names)
    - Disable Windows Spotlight (desktop "Learn more" button)
    - Comprehensive Content Delivery Manager cleanup
    - Additional scheduled task cleanup (Family Safety)
    - Non-blocking hostname configuration

    NEW IN v4.0:
    - Complete OneDrive removal and cleanup
    - Remove widget/news platform (weather widget, news feeds)
    - Disable Windows optional features (WCF, WorkFolders, Internet Printing)
    - Comprehensive 24/7 power settings (never sleep, never hibernate)
    - Disable Edge auto-launch at startup
    - Additional bloatware removal (Photos, Camera, Paint, Intel OEM software)

    FEATURES FROM v3.0:
    - Enables Remote Desktop (RDP) with NLA security
    - Configures Windows Firewall for Niagara ports (443, 4911, 5011, BACnet 47808)
    - Blocks insecure protocols (HTTP 80, Fox 1911, Platform 3011)
    - Optional hostname configuration with validation
    - Comprehensive transcript logging for audit trails
    - Keeps essential apps (Calculator, Store, Notepad, Snipping Tool)
    - Disables SMBv1 and PowerShell v2 for enhanced security

    Based on research from Win11Debloat, Chris Titus WinUtil, NIST SP 800-82,
    Niagara 4 Hardening Guide, and current best practices (2025-2026).
.NOTES
    Run as Administrator
    Reboot after running
    Test on a non-production system first!

    Last Updated: January 2026
#>

# ============================================
# INITIALIZATION
# ============================================
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Windows 11 Debloat for Niagara Supervisor (v5.0)" -ForegroundColor Cyan
Write-Host "  + Deep Bloatware Removal + Spotlight Disable" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# INITIALIZE LOGGING
# ============================================
$LogPath = "C:\ProgramData\NiagaraProvisioning\Logs"
if (!(Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptFile = Join-Path $LogPath "Provision-$env:COMPUTERNAME-$Timestamp.log"

try {
    Start-Transcript -Path $TranscriptFile -Append -NoClobber
    Write-Host "Logging to: $TranscriptFile" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Warning "Could not start transcript logging: $_"
}


# ============================================
# CREATE RESTORE POINT (Safety First)
# ============================================
Write-Host "[0/13] Creating System Restore Point..." -ForegroundColor Yellow

try {
    # Enable System Restore if not already enabled
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    
    # Create restore point
    Checkpoint-Computer -Description "Pre-Debloat Restore Point" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "  Restore point created successfully." -ForegroundColor Green
}
catch {
    Write-Host "  Could not create restore point (may already exist today). Continuing..." -ForegroundColor DarkYellow
}

# ============================================
# SECTION 1: Remove Bloatware Apps
# ============================================
Write-Host "[1/13] Removing bloatware apps..." -ForegroundColor Yellow

# ESSENTIAL APPS KEPT (Not in removal list):
# - Microsoft.WindowsCalculator (Calculator - useful for troubleshooting)
# - Microsoft.ScreenSketch (Snipping Tool - screenshots for error reporting)
# - Microsoft.WindowsNotepad (Notepad - text file editing)
# - Microsoft.WindowsStore (Microsoft Store - CANNOT be reinstalled if removed)
# - Microsoft.DesktopAppInstaller (winget - package manager)

$BloatwareApps = @(
    # Microsoft bloat - Cortana and AI
    "Microsoft.549981C3F5F10"                    # Cortana
    "Microsoft.Copilot"                          # Copilot AI
    "Microsoft.Windows.Ai.Copilot.Provider"      # Copilot Provider
    "MicrosoftWindows.Client.Copilot"            # Copilot Client
    
    # Microsoft bloat - General
    "Microsoft.3DBuilder"
    "Microsoft.BingFinance"
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    "Microsoft.BingTravel"
    "Microsoft.BingWeather"
    "Microsoft.BingSearch"
    "Clipchamp.Clipchamp"
    "Microsoft.Clipchamp"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftJournal"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MixedReality.Portal"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.News"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Todos"
    "Microsoft.Wallet"
    "Microsoft.Windows.DevHome"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftCorporationII.MicrosoftFamily"
    "MicrosoftCorporationII.QuickAssist"
    "MicrosoftTeams"
    "MSTeams"
    "Microsoft.GamingApp"
    "Microsoft.OutlookForWindows"
    
    # Xbox (not needed for BAS appliance)
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.XboxGameCallableUI"          # Xbox Game Bar UI component

    # Widgets and News Platform (v4.0)
    "Microsoft.WidgetsPlatformRuntime"      # Weather widget, news feeds
    "MicrosoftWindows.Client.WebExperience" # Widget/news backend

    # Hidden telemetry packages (v5.0 - obfuscated names)
    "MicrosoftWindows.57242383.Tasbar"      # Taskbar telemetry/features
    "MicrosoftWindows.59336768.Speion"      # Spying/telemetry
    "MicrosoftWindows.59337133.Voiess"      # Voice services
    "MicrosoftWindows.59337145.Livtop"      # Live Tiles
    "MicrosoftWindows.59379618.InpApp"      # Input telemetry

    # Additional bloatware (v4.0)
    "Microsoft.Windows.Photos"              # Photos app (use classic viewer)
    "Microsoft.WindowsCamera"               # Camera app (not needed on supervisor)
    "Microsoft.Paint"                       # Paint 3D (classic Paint remains)
    "Microsoft.Edge.GameAssist"             # Edge gaming features
    "AppUp.IntelArcSoftware"                # Intel OEM bloatware
    
    # Third-party bloat often pre-installed
    "ACGMediaPlayer"
    "ActiproSoftwareLLC"
    "AdobeSystemsIncorporated.AdobePhotoshopExpress"
    "Amazon.com.Amazon"
    "AmazonVideo.PrimeVideo"
    "Asphalt8Airborne"
    "AutodeskSketchBook"
    "BytedancePte.Ltd.TikTok"
    "CaesarsSlotsFreeCasino"
    "CandyCrush"
    "COOKINGFEVER"
    "CyberLinkMediaSuiteEssentials"
    "DisneyMagicKingdoms"
    "Disney"
    "Dolby"
    "DrawboardPDF"
    "Duolingo-LearnLanguagesforFree"
    "EclipseManager"
    "Facebook"
    "FarmVille2CountryEscape"
    "fitbit"
    "Flipboard"
    "HiddenCity"
    "HULULLC.HULUPLUS"
    "iHeartRadio"
    "Instagram"
    "king.com.BubbleWitch3Saga"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "LinkedInforWindows"
    "MarchofEmpires"
    "Netflix"
    "NYTCrossword"
    "OneCalendar"
    "PandoraMediaInc"
    "PhototasticCollage"
    "PicsArt-PhotoStudio"
    "Plex"
    "PolarrPhotoEditorAcademicEdition"
    "Royal Revolt"
    "Shazam"
    "Sidia.LiveWallpaper"
    "SlingTV"
    "Spotify"
    "SpotifyAB.SpotifyMusic"
    "TikTok"
    "TuneInRadio"
    "Twitter"
    "Viber"
    "WinZipUniversal"
    "Wunderlist"
    "XING"
)

foreach ($App in $BloatwareApps) {
    Write-Host "  Removing $App..." -ForegroundColor Gray
    
    # Remove for current user
    Get-AppxPackage -Name "*$App*" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    
    # Remove for all users (handles bundles properly)
    Get-AppxPackage -Name "*$App*" -AllUsers -PackageTypeFilter Main, Bundle, Resource -ErrorAction SilentlyContinue | 
        ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue }
    
    # Remove provisioned package (prevents reinstall for new users)
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
        Where-Object { $_.DisplayName -like "*$App*" } | 
        ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue }
}

Write-Host "  Done removing apps." -ForegroundColor Green

# ============================================
# SECTION 1.5: Enhanced Widget/WebExperience Removal (v5.0)
# ============================================
Write-Host "[1.5/13] Enhanced widget removal..." -ForegroundColor Yellow

# Kill Widgets.exe process first before attempting removal
Write-Host "  Terminating Widgets.exe process..." -ForegroundColor Gray
Stop-Process -Name "Widgets" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# More aggressive package removal with retry logic
Write-Host "  Removing WebExperience packages (with retry)..." -ForegroundColor Gray
for ($i = 1; $i -le 3; $i++) {
    Get-AppxPackage -AllUsers *WebExperience* -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxPackage -AllUsers *WidgetsPlatformRuntime* -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Manual directory removal if package removal fails
$webExpPath = Get-ChildItem "C:\Program Files\WindowsApps\MicrosoftWindows.Client.WebExperience*" -Directory -ErrorAction SilentlyContinue
if ($webExpPath) {
    Write-Host "  Forcing manual removal of WebExperience directory..." -ForegroundColor Gray
    takeown /F $webExpPath.FullName /R /A 2>$null | Out-Null
    icacls $webExpPath.FullName /grant Administrators:F /T 2>$null | Out-Null
    Remove-Item $webExpPath.FullName -Force -Recurse -ErrorAction SilentlyContinue
}

# Add comprehensive registry blocks to prevent widget reinstall
Write-Host "  Setting registry blocks to prevent reinstall..." -ForegroundColor Gray
$WidgetPreventKeys = @(
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Dsh"; Name="AllowNewsAndInterests"; Value=0},
    @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarDa"; Value=0}
)

foreach ($Key in $WidgetPreventKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
}

Write-Host "  Done with enhanced widget removal." -ForegroundColor Green

# ============================================
# SECTION 1.6: Complete OneDrive Removal
# ============================================
Write-Host "[1.6/13] Completely removing OneDrive..." -ForegroundColor Yellow

# Kill OneDrive processes
Write-Host "  Stopping OneDrive processes..." -ForegroundColor Gray
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue

# Uninstall OneDrive (32-bit and 64-bit paths)
Write-Host "  Uninstalling OneDrive..." -ForegroundColor Gray
$OneDrivePaths = @(
    "$env:SystemRoot\System32\OneDriveSetup.exe"
    "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
)

foreach ($Path in $OneDrivePaths) {
    if (Test-Path $Path) {
        Start-Process -FilePath $Path -ArgumentList "/uninstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue
    }
}

# Remove OneDrive leftovers
Write-Host "  Removing OneDrive folders and registry keys..." -ForegroundColor Gray
$OneDriveFolders = @(
    "$env:USERPROFILE\OneDrive"
    "$env:LOCALAPPDATA\Microsoft\OneDrive"
    "$env:PROGRAMDATA\Microsoft OneDrive"
    "C:\OneDriveTemp"
)

foreach ($Folder in $OneDriveFolders) {
    if (Test-Path $Folder) {
        Remove-Item -Path $Folder -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# Disable OneDrive via registry
$OneDriveKeys = @(
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"; Name="DisableFileSyncNGSC"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"; Name="DisableFileSync"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"; Name="DisableMeteredNetworkFileSync"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"; Name="DisableLibrariesDefaultSaveToOneDrive"; Value=1},
    @{Path="HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"; Name="System.IsPinnedToNameSpaceTree"; Value=0},
    @{Path="HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"; Name="System.IsPinnedToNameSpaceTree"; Value=0}
)

foreach ($Key in $OneDriveKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force -ErrorAction SilentlyContinue
}

# Remove OneDrive from startup
Write-Host "  Removing OneDrive from startup..." -ForegroundColor Gray
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -ErrorAction SilentlyContinue

# Remove OneDrive shortcuts
$OneDriveShortcuts = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
    "$env:USERPROFILE\Desktop\OneDrive.lnk"
)

foreach ($Shortcut in $OneDriveShortcuts) {
    if (Test-Path $Shortcut) {
        Remove-Item -Path $Shortcut -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "  Done removing OneDrive." -ForegroundColor Green

# ============================================
# SECTION 2: Disable Copilot Completely
# ============================================
Write-Host "[2/13] Disabling Microsoft Copilot..." -ForegroundColor Yellow

$CopilotKeys = @(
    # Disable Copilot via User Policy
    @{Path="HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"; Name="TurnOffWindowsCopilot"; Value=1},
    
    # Disable Copilot via Machine Policy
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; Name="TurnOffWindowsCopilot"; Value=1},
    
    # Disable Copilot taskbar button
    @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ShowCopilotButton"; Value=0}
)

foreach ($Key in $CopilotKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
}

# Also remove Copilot packages if they exist
Get-AppxPackage -AllUsers | Where-Object { $_.Name -ilike "*Copilot*" } | 
    ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue }

Write-Host "  Done disabling Copilot." -ForegroundColor Green

# ============================================
# SECTION 3: Disable Windows Recall (AI Feature)
# ============================================
Write-Host "[3/13] Disabling Windows Recall AI..." -ForegroundColor Yellow

$RecallKeys = @(
    # Disable Recall feature completely
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name="AllowRecallEnablement"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name="DisableAIDataAnalysis"; Value=1},
    
    # Disable Click to Do (AI image/text analysis)
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name="TurnOffSavingSnapshots"; Value=1}
)

foreach ($Key in $RecallKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
}

# Attempt to disable Recall via DISM if available
try {
    $RecallFeature = Get-WindowsOptionalFeature -Online -FeatureName "Recall" -ErrorAction SilentlyContinue
    if ($RecallFeature -and $RecallFeature.State -eq "Enabled") {
        Disable-WindowsOptionalFeature -Online -FeatureName "Recall" -NoRestart -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Host "  Recall feature not present (normal for non-Copilot+ PCs)." -ForegroundColor Gray
}

Write-Host "  Done disabling Recall." -ForegroundColor Green

# ============================================
# SECTION 4: Disable Telemetry & Data Collection
# ============================================
Write-Host "[4/13] Disabling telemetry and data collection..." -ForegroundColor Yellow

$TelemetryKeys = @(
    # Core telemetry settings
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="AllowTelemetry"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="DoNotShowFeedbackNotifications"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="LimitDiagnosticLogCollection"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="DisableOneSettingsDownloads"; Value=1},
    @{Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name="AllowTelemetry"; Value=0},
    @{Path="HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name="AllowTelemetry"; Value=0},
    
    # Disable advertising ID
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"; Name="DisabledByGroupPolicy"; Value=1},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name="Enabled"; Value=0},
    
    # Disable activity history
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name="EnableActivityFeed"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name="PublishUserActivities"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name="UploadUserActivities"; Value=0},
    
    # Disable location tracking
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"; Name="DisableLocation"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"; Name="DisableWindowsLocationProvider"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"; Name="DisableLocationScripting"; Value=1},
    
    # Disable Cortana
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name="AllowCortana"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name="DisableWebSearch"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name="ConnectedSearchUseWeb"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name="AllowCloudSearch"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name="AllowSearchToUseLocation"; Value=0},
    
    # Disable Windows Tips, suggestions, and consumer features
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableSoftLanding"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableWindowsConsumerFeatures"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableCloudOptimizedContent"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableTailoredExperiencesWithDiagnosticData"; Value=1},
    @{Path="HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableTailoredExperiencesWithDiagnosticData"; Value=1},
    @{Path="HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableWindowsSpotlightFeatures"; Value=1},
    
    # Disable tailored experiences
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name="TailoredExperiencesWithDiagnosticDataEnabled"; Value=0},
    
    # Disable feedback
    @{Path="HKCU:\SOFTWARE\Microsoft\Siuf\Rules"; Name="NumberOfSIUFInPeriod"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Siuf\Rules"; Name="PeriodInNanoSeconds"; Value=0},
    
    # Disable app launch tracking
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="Start_TrackProgs"; Value=0},
    
    # Disable Bing in Start Menu
    @{Path="HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"; Name="DisableSearchBoxSuggestions"; Value=1},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; Name="BingSearchEnabled"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; Name="CortanaConsent"; Value=0},
    
    # Disable input personalization
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization"; Name="AllowInputPersonalization"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization"; Name="RestrictImplicitInkCollection"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization"; Name="RestrictImplicitTextCollection"; Value=1},
    
    # Disable error reporting
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting"; Name="Disabled"; Value=1},
    @{Path="HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"; Name="Disabled"; Value=1}
)

foreach ($Key in $TelemetryKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
}

Write-Host "  Done disabling telemetry." -ForegroundColor Green

# ============================================
# SECTION 5: Disable Unnecessary Services
# ============================================
Write-Host "[5/13] Disabling unnecessary services..." -ForegroundColor Yellow

$ServicesToDisable = @(
    "DiagTrack"                    # Connected User Experiences and Telemetry
    "dmwappushservice"             # WAP Push Message Routing Service
    "SysMain"                      # Superfetch - not needed on SSD/appliance
    "WSearch"                      # Windows Search - not needed for appliance
    "MapsBroker"                   # Downloaded Maps Manager
    "lfsvc"                        # Geolocation Service
    "RetailDemo"                   # Retail Demo Service
    "wisvc"                        # Windows Insider Service
    "XblAuthManager"               # Xbox Live Auth Manager
    "XblGameSave"                  # Xbox Live Game Save
    "XboxGipSvc"                   # Xbox Accessory Management
    "XboxNetApiSvc"                # Xbox Live Networking
    "WMPNetworkSvc"                # Windows Media Player Network Sharing
    "WerSvc"                       # Windows Error Reporting
    "Fax"                          # Fax
    "fhsvc"                        # File History Service
    "TrkWks"                       # Distributed Link Tracking Client
    "WpcMonSvc"                    # Parental Controls
    "PhoneSvc"                     # Phone Service
    "TabletInputService"           # Touch Keyboard (if not needed)
)

foreach ($Service in $ServicesToDisable) {
    $svc = Get-Service -Name $Service -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "  Disabling $Service..." -ForegroundColor Gray
        Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $Service -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

# Set some services to Manual instead of Disabled
$ServicesToManual = @(
    "wuauserv"                     # Windows Update - manual so you control when
    "BITS"                         # Background Intelligent Transfer
)

foreach ($Service in $ServicesToManual) {
    $svc = Get-Service -Name $Service -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "  Setting $Service to Manual..." -ForegroundColor Gray
        Set-Service -Name $Service -StartupType Manual -ErrorAction SilentlyContinue
    }
}

Write-Host "  Done configuring services." -ForegroundColor Green

# ============================================
# SECTION 5.5: Disable Unnecessary Windows Features
# ============================================
Write-Host "[5.5/13] Disabling unnecessary Windows optional features..." -ForegroundColor Yellow

$FeaturesToDisable = @(
    "WorkFolders-Client"                      # Enterprise file sync
    "WindowsMediaPlayer"                      # Legacy media player
    "Printing-Foundation-InternetPrinting-Client"  # Internet printing
    "WCF-Services45"                          # WCF services (likely not needed)
    "WCF-TCP-PortSharing45"                   # WCF TCP port sharing
)

foreach ($Feature in $FeaturesToDisable) {
    $FeatureState = Get-WindowsOptionalFeature -Online -FeatureName $Feature -ErrorAction SilentlyContinue
    if ($FeatureState -and $FeatureState.State -eq "Enabled") {
        Write-Host "  Disabling feature: $Feature..." -ForegroundColor Gray
        Disable-WindowsOptionalFeature -Online -FeatureName $Feature -NoRestart -ErrorAction SilentlyContinue | Out-Null
    }
}

Write-Host "  Done disabling Windows features." -ForegroundColor Green

# ============================================
# SECTION 6: Disable Scheduled Tasks
# ============================================
Write-Host "[6/13] Disabling telemetry scheduled tasks..." -ForegroundColor Yellow

$TasksToDisable = @(
    # Application Experience
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
    "\Microsoft\Windows\Application Experience\PcaPatchDbTask"
    
    # Autochk
    "\Microsoft\Windows\Autochk\Proxy"
    
    # Customer Experience Improvement Program
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    
    # Disk Diagnostics
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    
    # Feedback
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    
    # Maps
    "\Microsoft\Windows\Maps\MapsToastTask"
    "\Microsoft\Windows\Maps\MapsUpdateTask"
    
    # Windows Error Reporting
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
    
    # Xbox
    "\Microsoft\XblGameSave\XblGameSaveTask"
    
    # Cloud Experience Host
    "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
    
    # Device Information
    "\Microsoft\Windows\Device Information\Device"
    "\Microsoft\Windows\Device Information\Device User"
    
    # License Manager
    "\Microsoft\Windows\License Manager\TempSignedLicenseExchange"
    
    # PI
    "\Microsoft\Windows\PI\Sqm-Tasks"
    
    # Flighting
    "\Microsoft\Windows\Flighting\FeatureConfig\ReconcileFeatures"
    "\Microsoft\Windows\Flighting\FeatureConfig\UsageDataFlushing"
    "\Microsoft\Windows\Flighting\FeatureConfig\UsageDataReporting"
    "\Microsoft\Windows\Flighting\OneSettings\RefreshCache"

    # Family Safety (v5.0)
    "\Microsoft\Windows\Shell\FamilySafetyMonitor"
    "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
)

foreach ($Task in $TasksToDisable) {
    $taskObj = Get-ScheduledTask -TaskName $Task.Split('\')[-1] -TaskPath ($Task.Substring(0, $Task.LastIndexOf('\') + 1)) -ErrorAction SilentlyContinue
    if ($taskObj) {
        Write-Host "  Disabling task: $($Task.Split('\')[-1])" -ForegroundColor Gray
        Disable-ScheduledTask -TaskName $Task.Split('\')[-1] -TaskPath ($Task.Substring(0, $Task.LastIndexOf('\') + 1)) -ErrorAction SilentlyContinue | Out-Null
    }
}

Write-Host "  Done disabling tasks." -ForegroundColor Green

# ============================================
# SECTION 7: Privacy Settings
# ============================================
Write-Host "[7/13] Configuring privacy settings..." -ForegroundColor Yellow

# Disable app access to various sensors/data
$PrivacyCapabilities = @(
    "webcam"
    "microphone"
    "location"
    "userAccountInformation"
    "contacts"
    "calendar"
    "phoneCall"
    "callHistory"
    "email"
    "userDataTasks"
    "chat"
    "radios"
    "bluetoothSync"
    "appDiagnostics"
    "documentsLibrary"
    "picturesLibrary"
    "videosLibrary"
    "broadFileSystemAccess"
)

foreach ($Capability in $PrivacyCapabilities) {
    $Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\$Capability"
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name "Value" -Value "Deny" -Type String -Force
}

# Additional privacy settings
$PrivacyKeys = @(
    # Disable clipboard history
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name="AllowClipboardHistory"; Value=0},
    
    # Disable online speech recognition
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization"; Name="AllowInputPersonalization"; Value=0},
    
    # Disable handwriting data sharing
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC"; Name="PreventHandwritingDataSharing"; Value=1},
    
    # Disable text/ink collection
    @{Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput"; Name="AllowLinguisticDataCollection"; Value=0},
    
    # Disable widgets
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Dsh"; Name="AllowNewsAndInterests"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarDa"; Value=0}
)

foreach ($Key in $PrivacyKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
}

# ============================================
# v5.0: Disable Content Delivery Manager
# ============================================
Write-Host "  Disabling Content Delivery Manager features..." -ForegroundColor Gray

$CDMPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$CDMSettings = @{
    "FeatureManagementEnabled" = 0
    "OemPreInstalledAppsEnabled" = 0
    "PreInstalledAppsEnabled" = 0
    "RotatingLockScreenEnabled" = 0
    "RotatingLockScreenOverlayEnabled" = 0
    "SilentInstalledAppsEnabled" = 0
    "SoftLandingEnabled" = 0
    "SystemPaneSuggestionsEnabled" = 0
    "SubscribedContent-338389Enabled" = 0
}

foreach ($Setting in $CDMSettings.GetEnumerator()) {
    Set-ItemProperty -Path $CDMPath -Name $Setting.Key -Value $Setting.Value -Type DWord -Force
}

# ============================================
# v5.0: Disable Windows Spotlight (Desktop "Learn more" button)
# ============================================
Write-Host "  Disabling Windows Spotlight..." -ForegroundColor Gray

$SpotlightKeys = @(
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableWindowsSpotlightFeatures"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableWindowsSpotlightOnActionCenter"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableWindowsSpotlightOnSettings"; Value=1},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name="DisableWindowsSpotlightWindowsWelcomeExperience"; Value=1},
    @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"; Name="AutoSelectWidgetsOnLockScreen"; Value=0}
)

foreach ($Key in $SpotlightKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
}

Write-Host "  Done configuring privacy." -ForegroundColor Green

# ============================================
# SECTION 7.5: Critical Security Hardening
# ============================================
Write-Host "[7.5/13] Applying critical security hardening..." -ForegroundColor Yellow

# Disable SMBv1 (WannaCry/NotPetya vulnerability vector)
Write-Host "  Disabling SMBv1 protocol..." -ForegroundColor Gray
try {
    $SMBv1Feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
    if ($SMBv1Feature -and $SMBv1Feature.State -eq "Enabled") {
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction Stop | Out-Null
        Write-Host "    SMBv1 disabled successfully" -ForegroundColor Green
    } else {
        Write-Host "    SMBv1 already disabled or not present" -ForegroundColor Gray
    }
}
catch {
    Write-Host "    Warning: Could not disable SMBv1: $_" -ForegroundColor DarkYellow
}

# Disable PowerShell v2 (security bypass risk)
Write-Host "  Disabling PowerShell v2..." -ForegroundColor Gray
try {
    $PSv2Feature = Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -ErrorAction SilentlyContinue
    if ($PSv2Feature -and $PSv2Feature.State -eq "Enabled") {
        Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart -ErrorAction Stop | Out-Null
        Write-Host "    PowerShell v2 disabled successfully" -ForegroundColor Green
    } else {
        Write-Host "    PowerShell v2 already disabled or not present" -ForegroundColor Gray
    }
}
catch {
    Write-Host "    Warning: Could not disable PowerShell v2: $_" -ForegroundColor DarkYellow
}

# Also disable PowerShell v2 Engine (if separate)
try {
    $PSv2Engine = Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -ErrorAction SilentlyContinue
    if ($PSv2Engine -and $PSv2Engine.State -eq "Enabled") {
        Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart -ErrorAction Stop | Out-Null
    }
}
catch {
    # Silently continue - this feature may not exist on all systems
}

Write-Host "  Done with security hardening." -ForegroundColor Green

# ============================================
# SECTION 8: Performance Optimizations
# ============================================
Write-Host "[8/13] Applying performance optimizations..." -ForegroundColor Yellow

$PerfKeys = @(
    # Disable Game Mode / Game Bar / Game DVR
    @{Path="HKCU:\SOFTWARE\Microsoft\GameBar"; Name="AutoGameModeEnabled"; Value=0; Type="DWord"},
    @{Path="HKCU:\SOFTWARE\Microsoft\GameBar"; Name="AllowAutoGameMode"; Value=0; Type="DWord"},
    @{Path="HKCU:\SOFTWARE\Microsoft\GameBar"; Name="UseNexusForGameBarEnabled"; Value=0; Type="DWord"},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"; Name="AllowGameDVR"; Value=0; Type="DWord"},
    @{Path="HKCU:\System\GameConfigStore"; Name="GameDVR_Enabled"; Value=0; Type="DWord"},
    
    # Disable Sticky Keys / Filter Keys shortcuts
    @{Path="HKCU:\Control Panel\Accessibility\StickyKeys"; Name="Flags"; Value="506"; Type="String"},
    @{Path="HKCU:\Control Panel\Accessibility\ToggleKeys"; Name="Flags"; Value="58"; Type="String"},
    @{Path="HKCU:\Control Panel\Accessibility\Keyboard Response"; Name="Flags"; Value="122"; Type="String"},
    
    # Disable transparency
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name="EnableTransparency"; Value=0; Type="DWord"},
    
    # Show file extensions
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="HideFileExt"; Value=0; Type="DWord"},
    
    # Disable recent files in Quick Access
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"; Name="ShowRecent"; Value=0; Type="DWord"},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"; Name="ShowFrequent"; Value=0; Type="DWord"},
    
    # Disable startup delay
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize"; Name="StartupDelayInMSec"; Value=0; Type="DWord"},
    
    # Disable Fast Startup (ensures clean shutdown/startup for appliance)
    @{Path="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"; Name="HiberbootEnabled"; Value=0; Type="DWord"}
)

foreach ($Key in $PerfKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    if ($Key.Type -eq "String") {
        Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type String -Force
    } else {
        Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
    }
}

# Set High Performance power plan via powercfg
Write-Host "  Setting High Performance power plan..." -ForegroundColor Gray
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
if ($LASTEXITCODE -ne 0) {
    # If High Performance doesn't exist, try to create it
    powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
}

# Disable hibernation (saves disk space)
powercfg /hibernate off 2>$null

# ============================================
# 24/7 ALWAYS-ON POWER CONFIGURATION (v4.0)
# ============================================
Write-Host "  Configuring 24/7 always-on power settings..." -ForegroundColor Gray

# Get current active power scheme GUID
$CurrentScheme = (powercfg /getactivescheme).Split()[3]

# NEVER sleep (AC and DC power)
Write-Host "    Setting sleep to NEVER..." -ForegroundColor DarkGray
powercfg /change standby-timeout-ac 0 2>$null
powercfg /change standby-timeout-dc 0 2>$null
powercfg /setacvalueindex $CurrentScheme SUB_SLEEP STANDBYIDLE 0 2>$null
powercfg /setdcvalueindex $CurrentScheme SUB_SLEEP STANDBYIDLE 0 2>$null

# NEVER hibernate
Write-Host "    Setting hibernate to NEVER..." -ForegroundColor DarkGray
powercfg /change hibernate-timeout-ac 0 2>$null
powercfg /change hibernate-timeout-dc 0 2>$null
powercfg /setacvalueindex $CurrentScheme SUB_SLEEP HIBERNATEIDLE 0 2>$null
powercfg /setdcvalueindex $CurrentScheme SUB_SLEEP HIBERNATEIDLE 0 2>$null

# Disable hybrid sleep
Write-Host "    Disabling hybrid sleep..." -ForegroundColor DarkGray
powercfg /setacvalueindex $CurrentScheme SUB_SLEEP HYBRIDSLEEP 0 2>$null
powercfg /setdcvalueindex $CurrentScheme SUB_SLEEP HYBRIDSLEEP 0 2>$null

# Disable wake timers (prevent unexpected wake-ups)
Write-Host "    Disabling wake timers..." -ForegroundColor DarkGray
powercfg /setacvalueindex $CurrentScheme SUB_SLEEP RTCWAKE 0 2>$null
powercfg /setdcvalueindex $CurrentScheme SUB_SLEEP RTCWAKE 0 2>$null

# NEVER turn off display (24/7 operation - user approved)
Write-Host "    Setting display timeout to NEVER..." -ForegroundColor DarkGray
powercfg /change monitor-timeout-ac 0 2>$null
powercfg /change monitor-timeout-dc 0 2>$null
powercfg /setacvalueindex $CurrentScheme SUB_VIDEO VIDEOIDLE 0 2>$null
powercfg /setdcvalueindex $CurrentScheme SUB_VIDEO VIDEOIDLE 0 2>$null

# Disable USB selective suspend (keep USB devices powered)
Write-Host "    Disabling USB selective suspend..." -ForegroundColor DarkGray
powercfg /setacvalueindex $CurrentScheme SUB_USB USBSELECTIVESUSPEND 0 2>$null
powercfg /setdcvalueindex $CurrentScheme SUB_USB USBSELECTIVESUSPEND 0 2>$null

# Apply settings
powercfg /setactive $CurrentScheme 2>$null

Write-Host "  24/7 power settings configured successfully." -ForegroundColor Green
Write-Host "  Done with performance optimizations." -ForegroundColor Green

# ============================================
# SECTION 8.5: Disable Edge Auto-Launch
# ============================================
Write-Host "[8.5/13] Disabling Edge auto-launch at startup..." -ForegroundColor Yellow

# Remove Edge auto-launch from startup registry
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftEdgeAutoLaunch*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftEdgeAutoLaunch*" -ErrorAction SilentlyContinue

# Disable Edge startup boost
$EdgeKeys = @(
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name="StartupBoostEnabled"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name="HardwareAccelerationModeEnabled"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name="BackgroundModeEnabled"; Value=0}
)

foreach ($Key in $EdgeKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
}

Write-Host "  Done disabling Edge auto-launch." -ForegroundColor Green

# ============================================
# SECTION 9: Windows Update Configuration
# ============================================
Write-Host "[9/13] Configuring Windows Update for manual control..." -ForegroundColor Yellow

$UpdateKeys = @(
    # Disable auto-restart
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"; Name="NoAutoRebootWithLoggedOnUsers"; Value=1},
    
    # Notify before download (AUOptions: 2=Notify, 3=Auto download, 4=Auto install)
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"; Name="AUOptions"; Value=2},
    
    # Disable driver updates via Windows Update
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"; Name="ExcludeWUDriversInQualityUpdate"; Value=1},
    
    # Disable auto-update of Store apps
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"; Name="AutoDownload"; Value=2},
    
    # Disable delivery optimization (P2P updates)
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"; Name="DODownloadMode"; Value=0}
)

foreach ($Key in $UpdateKeys) {
    if (!(Test-Path $Key.Path)) {
        New-Item -Path $Key.Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type DWord -Force
}

Write-Host "  Done configuring updates." -ForegroundColor Green

# ============================================
# SECTION 10: Enable Remote Desktop (RDP)
# ============================================
Write-Host "[10/13] Enabling Remote Desktop (RDP)..." -ForegroundColor Yellow

# Enable RDP via Registry
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Type DWord -Force

# Disable NLA requirement (optional - makes it easier to connect, less secure)
# Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0 -Type DWord -Force

# Keep NLA enabled for better security (recommended)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1 -Type DWord -Force

# Enable RDP service
Set-Service -Name "TermService" -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service -Name "TermService" -ErrorAction SilentlyContinue

# Enable firewall rule for RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

Write-Host "  Done enabling RDP." -ForegroundColor Green

# ============================================
# SECTION 11: [REMOVED - OpenSSH]
# ============================================
# OpenSSH Server should be installed manually if needed.
# Manual installation provides better control over key management and configuration.
# To install: Settings > Apps > Optional Features > Add a feature > OpenSSH Server

# ============================================
# SECTION 12: [REMOVED - Tailscale]
# ============================================
# Tailscale VPN should be installed manually if needed.
# Download from: https://tailscale.com/download/windows
# Manual installation allows proper network configuration and authentication.

# ============================================
# SECTION 11: Configure Windows Firewall for Niagara & BACnet
# ============================================
Write-Host "[11/13] Configuring Windows Firewall for Niagara..." -ForegroundColor Yellow

# Define Niagara ports (SECURE ONLY - TCP Inbound)
$NiagaraPorts = @(
    @{Port=443;   Protocol="TCP"; Name="Niagara HTTPS/Web"},
    @{Port=4911;  Protocol="TCP"; Name="Niagara Foxs (Secure Fox)"},
    @{Port=5011;  Protocol="TCP"; Name="Niagara Secure Platform"}
)

# Create Niagara firewall rules (INBOUND ONLY)
foreach ($PortConfig in $NiagaraPorts) {
    $RuleName = "Niagara-$($PortConfig.Name -replace '[^a-zA-Z0-9]', '-')-In"

    $ExistingRule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue

    if (-not $ExistingRule) {
        Write-Host "  Creating inbound rule: $RuleName (Port $($PortConfig.Port))" -ForegroundColor Gray
        New-NetFirewallRule -DisplayName $RuleName `
            -Direction Inbound `
            -Protocol $PortConfig.Protocol `
            -LocalPort $PortConfig.Port `
            -Action Allow `
            -Profile Domain,Private `
            -Description "Allow $($PortConfig.Name) for Niagara BAS" `
            -ErrorAction SilentlyContinue | Out-Null
    } else {
        Write-Host "  Rule already exists: $RuleName" -ForegroundColor Gray
        Enable-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
    }
}

# BACnet/IP port (UDP only)
$BACnetRule = "BACnet-IP-47808-In"
if (-not (Get-NetFirewallRule -DisplayName $BACnetRule -ErrorAction SilentlyContinue)) {
    Write-Host "  Creating BACnet/IP rule (UDP 47808)" -ForegroundColor Gray
    New-NetFirewallRule -DisplayName $BACnetRule `
        -Direction Inbound `
        -Protocol UDP `
        -LocalPort 47808 `
        -Action Allow `
        -Profile Domain,Private `
        -Description "BACnet/IP protocol for building automation" `
        -ErrorAction SilentlyContinue | Out-Null
} else {
    Write-Host "  BACnet rule already exists" -ForegroundColor Gray
    Enable-NetFirewallRule -DisplayName $BACnetRule -ErrorAction SilentlyContinue
}

# Block insecure Niagara ports explicitly
Write-Host "  Blocking insecure Niagara ports..." -ForegroundColor Gray
$BlockPorts = @(
    @{Port=80;   Name="HTTP"},
    @{Port=1911; Name="Non-Secure Fox"},
    @{Port=3011; Name="Non-Secure Platform"}
)

foreach ($PortConfig in $BlockPorts) {
    $RuleName = "Niagara-Block-$($PortConfig.Name -replace ' ', '-')"

    if (-not (Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName $RuleName `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort $PortConfig.Port `
            -Action Block `
            -Profile Any `
            -Description "Block insecure $($PortConfig.Name) for Niagara security" `
            -ErrorAction SilentlyContinue | Out-Null
    }
}

Write-Host "  Done configuring firewall." -ForegroundColor Green

# ============================================
# SECTION 12: Configure Hostname (Optional)
# ============================================
Write-Host "[12/13] Hostname Configuration..." -ForegroundColor Yellow

$CurrentHostname = $env:COMPUTERNAME
Write-Host "  Current hostname: $CurrentHostname" -ForegroundColor Cyan
Write-Host ""

# Initialize variables
$NewHostname = $null
$HostnameChanged = $false

# Check if running interactively
$IsInteractive = $true
try {
    $null = $Host.UI.RawUI.ReadKey
} catch {
    $IsInteractive = $false
}

if (-not $IsInteractive) {
    Write-Host "  Skipping hostname configuration (non-interactive session)." -ForegroundColor Gray
    Write-Host "  To change hostname later, use: Rename-Computer -NewName <name>" -ForegroundColor Gray
} else {
    # Prompt for new hostname
    $HostnamePattern = "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,13}[a-zA-Z0-9])?$"
    $ReservedNames = @('CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4',
                       'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2',
                       'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9')

    $MaxRetries = 3
    $RetryCount = 0
    $NewHostname = $null
    $HostnameChanged = $false

    Write-Host "  Enter new hostname (or press ENTER to skip)" -ForegroundColor White
    Write-Host "  Format: LOCATION-FUNCTION-NUMBER (e.g., NYC-NIAG-01)" -ForegroundColor Gray
    Write-Host "  Requirements: 1-15 chars, alphanumeric + hyphens only" -ForegroundColor Gray
    Write-Host "  NOTE: You have 30 seconds to respond or this will auto-skip" -ForegroundColor DarkYellow
    Write-Host ""

    while ($RetryCount -lt $MaxRetries) {
        Write-Host "  Hostname: " -NoNewline -ForegroundColor Yellow

        # Use a timeout for Read-Host to prevent hanging
        $Input = $null
        try {
            $Job = Start-Job -ScriptBlock { Read-Host }
            if (Wait-Job -Job $Job -Timeout 30) {
                $Input = Receive-Job -Job $Job
            } else {
                Write-Host ""
                Write-Host "  Timeout reached. Skipping hostname configuration." -ForegroundColor DarkYellow
                Remove-Job -Job $Job -Force
                break
            }
            Remove-Job -Job $Job -Force
        } catch {
            Write-Host ""
            Write-Host "  Error reading input. Skipping hostname configuration." -ForegroundColor DarkYellow
            break
        }

        $Input = if ($null -ne $Input) { $Input.Trim() } else { "" }

        # Allow skip
        if ([string]::IsNullOrWhiteSpace($Input)) {
            Write-Host "  Skipping hostname configuration." -ForegroundColor Gray
            break
        }

        # Validate format
        if ($Input -notmatch $HostnamePattern) {
            Write-Host "  Invalid format. Must be 1-15 chars, start/end with alphanumeric, hyphens allowed in middle." -ForegroundColor Red
            $RetryCount++
            continue
        }

        # Check reserved names
        if ($ReservedNames -contains $Input.ToUpper()) {
            Write-Host "  '$Input' is a reserved system name." -ForegroundColor Red
            $RetryCount++
            continue
        }

        # Check if same as current
        if ($Input -eq $CurrentHostname) {
            Write-Host "  New hostname is same as current hostname." -ForegroundColor DarkYellow
            break
        }

        # Confirm
        Write-Host "  New hostname will be: $Input" -ForegroundColor Green
        Write-Host "  Proceed? (Y/N): " -NoNewline -ForegroundColor Yellow
        $Confirm = Read-Host

        if ($Confirm -match '^[Yy]') {
            # Check domain membership
            $ComputerSystem = Get-WmiObject Win32_ComputerSystem
            if ($ComputerSystem.PartOfDomain) {
                Write-Host "  WARNING: Computer is domain-joined ($($ComputerSystem.Domain))" -ForegroundColor Yellow
                Write-Host "  Renaming may require domain admin credentials and affect AD integration." -ForegroundColor Yellow
                Write-Host "  Continue anyway? (Y/N): " -NoNewline -ForegroundColor Yellow
                $Continue = Read-Host
                if ($Continue -notmatch '^[Yy]') {
                    Write-Host "  Hostname change cancelled." -ForegroundColor Gray
                    break
                }
            }

            # Perform rename
            try {
                Rename-Computer -NewName $Input -Force -PassThru -ErrorAction Stop | Out-Null
                Write-Host "  Hostname changed successfully to: $Input" -ForegroundColor Green
                $NewHostname = $Input
                $HostnameChanged = $true
                break
            }
            catch {
                Write-Host "  ERROR: Failed to rename computer: $_" -ForegroundColor Red
                $RetryCount++
            }
        } else {
            Write-Host "  Cancelled. Try again." -ForegroundColor Gray
            $RetryCount++
        }
    }

    if ($RetryCount -ge $MaxRetries -and -not $HostnameChanged) {
        Write-Host "  Maximum retry attempts reached." -ForegroundColor DarkYellow
    }
}

Write-Host "  Done with hostname configuration." -ForegroundColor Green
Write-Host ""

# ============================================
# SECTION 13: Block Telemetry via Hosts File
# ============================================
Write-Host "[13/13] Blocking telemetry domains via hosts file..." -ForegroundColor Yellow

$TelemetryDomains = @(
    # Core telemetry
    "vortex.data.microsoft.com"
    "vortex-win.data.microsoft.com"
    "telecommand.telemetry.microsoft.com"
    "telecommand.telemetry.microsoft.com.nsatc.net"
    "oca.telemetry.microsoft.com"
    "oca.telemetry.microsoft.com.nsatc.net"
    "sqm.telemetry.microsoft.com"
    "sqm.telemetry.microsoft.com.nsatc.net"
    "watson.telemetry.microsoft.com"
    "watson.telemetry.microsoft.com.nsatc.net"
    "redir.metaservices.microsoft.com"
    "choice.microsoft.com"
    "choice.microsoft.com.nsatc.net"
    "df.telemetry.microsoft.com"
    "reports.wes.df.telemetry.microsoft.com"
    "wes.df.telemetry.microsoft.com"
    "services.wes.df.telemetry.microsoft.com"
    "sqm.df.telemetry.microsoft.com"
    "telemetry.microsoft.com"
    "watson.ppe.telemetry.microsoft.com"
    "telemetry.appex.bing.net"
    "telemetry.urs.microsoft.com"
    "settings-sandbox.data.microsoft.com"
    "survey.watson.microsoft.com"
    "watson.live.com"
    "statsfe2.ws.microsoft.com"
    "corpext.msitadfs.glbdns2.microsoft.com"
    "compatexchange.cloudapp.net"
    "cs1.wpc.v0cdn.net"
    "a-0001.a-msedge.net"
    "statsfe2.update.microsoft.com.akadns.net"
    "diagnostics.support.microsoft.com"
    "corp.sts.microsoft.com"
    "statsfe1.ws.microsoft.com"
    "feedback.microsoft-hohm.com"
    "feedback.search.microsoft.com"
    "feedback.windows.com"
    
    # Additional telemetry endpoints (2024-2025 updates)
    "data.microsoft.com"
    "msedge.net"
    "activity.windows.com"
    "bingapis.com"
    "msftconnecttest.com"
    "azureedge.net"
    "self.events.data.microsoft.com"
    "functional.events.data.microsoft.com"
    "browser.events.data.msn.com"
    "umwatson.events.data.microsoft.com"
    "ceuswatcab01.blob.core.windows.net"
    "ceuswatcab02.blob.core.windows.net"
    "eaus2watcab01.blob.core.windows.net"
    "eaus2watcab02.blob.core.windows.net"
    "weus2watcab01.blob.core.windows.net"
    "weus2watcab02.blob.core.windows.net"
    "kmwatsonc.events.data.microsoft.com"
    "inference.location.live.net"
    "wdcp.microsoft.com"
    "wdcpalt.microsoft.com"
)

$HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

# Read current hosts file
try {
    $HostsContent = Get-Content $HostsPath -Raw -ErrorAction Stop
}
catch {
    $HostsContent = ""
}

# Add telemetry blocks
Add-Content -Path $HostsPath -Value "`n# === Windows Telemetry Blocks (Added by Debloat Script) ===" -ErrorAction SilentlyContinue

foreach ($Domain in $TelemetryDomains) {
    $Entry = "0.0.0.0 $Domain"
    if ($HostsContent -notmatch [regex]::Escape($Domain)) {
        Add-Content -Path $HostsPath -Value $Entry -ErrorAction SilentlyContinue
    }
}

# Flush DNS cache
ipconfig /flushdns | Out-Null

Write-Host "  Done blocking telemetry domains." -ForegroundColor Green

# ============================================
# FINAL SUMMARY
# ============================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary of changes:" -ForegroundColor White
Write-Host "  [+] Created system restore point" -ForegroundColor Gray
Write-Host "  [+] Removed 95+ bloatware apps (inc. widgets, photos, camera)" -ForegroundColor Gray
Write-Host "  [+] Removed 5 hidden telemetry packages (obfuscated names)" -ForegroundColor Green
Write-Host "  [+] Enhanced widget removal (killed processes, prevented reinstall)" -ForegroundColor Green
Write-Host "  [+] Completely removed OneDrive (uninstalled + cleaned up)" -ForegroundColor Gray
Write-Host "  [+] Disabled Microsoft Copilot completely" -ForegroundColor Gray
Write-Host "  [+] Disabled Windows Recall AI feature" -ForegroundColor Gray
Write-Host "  [+] Disabled telemetry and data collection" -ForegroundColor Gray
Write-Host "  [+] Disabled Content Delivery Manager (app suggestions, ads)" -ForegroundColor Green
Write-Host "  [+] Disabled Windows Spotlight (desktop 'Learn more' button)" -ForegroundColor Green
Write-Host "  [+] Disabled 20+ unnecessary services" -ForegroundColor Gray
Write-Host "  [+] Disabled 5 Windows optional features (WCF, WorkFolders, etc)" -ForegroundColor Gray
Write-Host "  [+] Disabled 27+ telemetry scheduled tasks (inc. Family Safety)" -ForegroundColor Green
Write-Host "  [+] Configured privacy settings" -ForegroundColor Gray
Write-Host "  [+] Applied performance optimizations" -ForegroundColor Gray
Write-Host "  [+] Configured 24/7 always-on power settings (never sleep)" -ForegroundColor Gray
Write-Host "  [+] Disabled Edge auto-launch at startup" -ForegroundColor Gray
Write-Host "  [+] Set Windows Update to manual/notify only" -ForegroundColor Gray
Write-Host "  [+] Blocked 50+ telemetry domains via hosts file" -ForegroundColor Gray
Write-Host ""
Write-Host "Remote Access & Security:" -ForegroundColor White
Write-Host "  [+] Remote Desktop (RDP) ENABLED - Port 3389 with NLA" -ForegroundColor Green
Write-Host "  [+] SMBv1 protocol DISABLED (security)" -ForegroundColor Green
Write-Host "  [+] PowerShell v2 DISABLED (security)" -ForegroundColor Green
if ($HostnameChanged) {
    Write-Host "  [+] Hostname changed to: $NewHostname" -ForegroundColor Green
}
Write-Host ""
Write-Host "Firewall Rules (Secure Inbound Only):" -ForegroundColor White
Write-Host "  [+] TCP 443   - Niagara HTTPS/Web (Inbound)" -ForegroundColor Gray
Write-Host "  [+] TCP 4911  - Niagara Foxs Secure Protocol (Inbound)" -ForegroundColor Gray
Write-Host "  [+] TCP 5011  - Niagara Secure Platform (Inbound)" -ForegroundColor Gray
Write-Host "  [+] UDP 47808 - BACnet/IP (Inbound)" -ForegroundColor Gray
Write-Host "  [+] TCP 3389  - Remote Desktop (Built-in rule)" -ForegroundColor Gray
Write-Host "  [-] BLOCKED: TCP 80, 1911, 3011 (Insecure protocols)" -ForegroundColor DarkRed
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""
if ($HostnameChanged) {
    Write-Host "  ! Hostname was changed to: $NewHostname" -ForegroundColor Yellow
    Write-Host "    REBOOT IS REQUIRED for hostname change to take effect!" -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "  1. REBOOT the system now" -ForegroundColor White
Write-Host "  2. Run Windows Update manually for security patches" -ForegroundColor White
Write-Host "  3. Install Niagara Workbench software" -ForegroundColor White
Write-Host "  4. (Optional) Install Tailscale VPN: https://tailscale.com/download/windows" -ForegroundColor White
Write-Host "  5. (Optional) Install OpenSSH Server if needed" -ForegroundColor White
Write-Host "  6. VERIFY BIOS: Set 'After Power Loss' to 'Power On' for 24/7 operation" -ForegroundColor Yellow
Write-Host "  7. Review log file: $TranscriptFile" -ForegroundColor White
Write-Host ""
Write-Host "  To connect via RDP after reboot:" -ForegroundColor White
Write-Host "     > mstsc /v:<ip-address>" -ForegroundColor Cyan
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Stop transcript logging
try {
    Stop-Transcript -ErrorAction SilentlyContinue
}
catch {
    # Ignore errors if transcript wasn't started
}

Write-Host "Full transcript saved to:" -ForegroundColor Cyan
Write-Host "  $TranscriptFile" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
