# Changelog

All notable changes to the Windows 11 Niagara Debloat Script will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.0.0] - 2026-01-22

### Added - Deep Bloatware Removal
- **Enhanced Widget Removal (Section 1.5)**
  - Kills `Widgets.exe` process before attempting removal
  - 3-attempt retry logic for WebExperience package removal
  - Manual directory removal with `takeown`/`icacls` if package removal fails
  - Registry blocks to prevent widget reinstall
  - Fixes weather widget appearing in taskbar

- **Hidden Telemetry Package Removal (Section 1)**
  - Added 5 obfuscated telemetry packages to removal list:
    - MicrosoftWindows.57242383.Tasbar (Taskbar telemetry)
    - MicrosoftWindows.59336768.Speion (Spying/telemetry)
    - MicrosoftWindows.59337133.Voiess (Voice services)
    - MicrosoftWindows.59337145.Livtop (Live Tiles)
    - MicrosoftWindows.59379618.InpApp (Input telemetry)

- **Content Delivery Manager Cleanup (Section 7)**
  - Disables 9 Content Delivery Manager settings:
    - FeatureManagementEnabled
    - OemPreInstalledAppsEnabled
    - PreInstalledAppsEnabled
    - RotatingLockScreenEnabled
    - RotatingLockScreenOverlayEnabled
    - SilentInstalledAppsEnabled
    - SoftLandingEnabled
    - SystemPaneSuggestionsEnabled
    - SubscribedContent-338389Enabled
  - Prevents app suggestions, lock screen ads, and silent app installs

- **Windows Spotlight Disablement (Section 7)**
  - Added 5 registry keys to disable Windows Spotlight:
    - DisableWindowsSpotlightFeatures
    - DisableWindowsSpotlightOnActionCenter
    - DisableWindowsSpotlightOnSettings
    - DisableWindowsSpotlightWindowsWelcomeExperience
    - AutoSelectWidgetsOnLockScreen
  - Fixes desktop wallpaper "Learn more" button issue

- **Additional Scheduled Tasks (Section 6)**
  - FamilySafetyMonitor
  - FamilySafetyRefreshTask

### Changed
- **Non-Blocking Hostname Configuration (Section 12)**
  - Detects non-interactive SSH sessions and auto-skips
  - Implements 30-second timeout using PowerShell jobs
  - Prevents exit code 137 (killed process) errors during remote execution
  - Graceful handling of background/remote sessions

- **Updated section numbering** from 12 to 13 sections
- **Updated summary** to reflect 95+ apps removed (was 90+)
- **Updated task count** to 27+ scheduled tasks disabled (was 25+)

### Fixed
- Weather widget still appearing in taskbar after v4.0
- Desktop wallpaper "Learn more" button persisting
- Script hanging on hostname prompt during non-interactive sessions
- WebExperience package not being fully removed

## [4.0.0] - 2026-01-22

### Added
- **Complete OneDrive Removal (Section 1.5)**
  - Uninstalls OneDrive from both 32-bit and 64-bit paths
  - Removes all OneDrive folders and registry keys
  - Removes OneDrive from startup
  - Removes OneDrive shortcuts

- **Widget/News Platform Removal (Section 1)**
  - Microsoft.WidgetsPlatformRuntime (weather widget, news feeds)
  - MicrosoftWindows.Client.WebExperience (widget/news backend)

- **Additional Bloatware Removal (Section 1)**
  - Microsoft.Windows.Photos
  - Microsoft.WindowsCamera
  - Microsoft.Paint (Paint 3D)
  - Microsoft.Edge.GameAssist
  - AppUp.IntelArcSoftware (Intel OEM bloatware)

- **Disable Windows Optional Features (Section 5.5)**
  - WorkFolders-Client
  - WindowsMediaPlayer
  - Printing-Foundation-InternetPrinting-Client
  - WCF-Services45
  - WCF-TCP-PortSharing45

- **24/7 Always-On Power Configuration (Section 8)**
  - Sets sleep to NEVER (AC and DC)
  - Sets hibernate to NEVER
  - Disables hybrid sleep
  - Disables wake timers
  - Sets display timeout to NEVER
  - Disables USB selective suspend
  - Comprehensive 24/7 operation support

- **Disable Edge Auto-Launch (Section 8.5)**
  - Removes Edge auto-launch from startup registry
  - Disables Edge startup boost
  - Disables Edge hardware acceleration
  - Disables Edge background mode

### Changed
- Updated from 11 sections to 12 sections
- Enhanced documentation for 24/7 supervisor appliance use

## [3.0.0] - 2025-12-15

### Added
- **Remote Desktop (RDP) Configuration (Section 10)**
  - Enables RDP with NLA security
  - Configures TermService for automatic startup
  - Enables Windows Firewall rules for Remote Desktop

- **Niagara Firewall Configuration (Section 11)**
  - Allows secure Niagara ports (TCP 443, 4911, 5011)
  - Allows BACnet/IP (UDP 47808)
  - Blocks insecure Niagara ports (TCP 80, 1911, 3011)

- **Security Hardening (Section 7.5)**
  - Disables SMBv1 protocol (WannaCry/NotPetya protection)
  - Disables PowerShell v2 (security bypass protection)

- **Hostname Configuration (Section 12)**
  - Optional hostname configuration with validation
  - Validates format (1-15 chars, alphanumeric + hyphens)
  - Checks for reserved system names
  - Domain membership detection and warnings
  - 3 retry attempts with confirmation

### Changed
- Expanded from 9 sections to 12 sections
- Enhanced security focus for building automation systems

## [2.0.0] - 2025-11-01

### Added
- **Telemetry Hosts File Blocking**
  - Blocks 50+ Microsoft telemetry domains via hosts file
  - Includes 2024-2025 updated endpoints
  - Flushes DNS cache after modification

- **Privacy Capability Restrictions**
  - Restricts app access to webcam, microphone, location
  - Restricts access to contacts, calendar, email, documents
  - Denies access to 17 different capability types

- **Additional Privacy Settings**
  - Disables clipboard history
  - Disables online speech recognition
  - Prevents handwriting data sharing
  - Disables linguistic data collection

### Changed
- Improved script organization and comments
- Added more detailed output messages
- Enhanced error handling

## [1.0.0] - 2025-10-01

### Initial Release
- Remove 60+ Microsoft bloatware apps
- Remove 35+ third-party bloatware apps
- Disable Microsoft Copilot
- Disable Windows Recall AI
- Disable telemetry and data collection
- Disable 20+ unnecessary services
- Disable 20+ telemetry scheduled tasks
- Configure privacy settings
- Apply performance optimizations
- Set Windows Update to manual control
- Create system restore point for safety
- Comprehensive transcript logging

---

## Release Notes Format

### [Version] - YYYY-MM-DD
#### Added
- New features

#### Changed
- Changes to existing functionality

#### Deprecated
- Soon-to-be removed features

#### Removed
- Removed features

#### Fixed
- Bug fixes

#### Security
- Security improvements
