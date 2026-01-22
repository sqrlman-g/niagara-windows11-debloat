# Windows 11 Debloat for Niagara Supervisor Appliances

A comprehensive PowerShell script to remove bloatware, disable telemetry, and optimize Windows 11 for use as a dedicated Niagara building automation supervisor operating 24/7.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-11-0078D6.svg)](https://www.microsoft.com/windows)

## 🚀 Quick Start

### One-Line Install (Recommended)

Run this command in an **elevated PowerShell** window (Run as Administrator):

```powershell
irm https://raw.githubusercontent.com/sqrlman-g/niagara-windows11-debloat/main/install.ps1 | iex
```

### Manual Install

1. Download the script:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sqrlman-g/niagara-windows11-debloat/main/windows11-niagara-debloat.ps1" -OutFile "windows11-niagara-debloat.ps1"
   ```

2. Run as Administrator:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\windows11-niagara-debloat.ps1
   ```

## ✨ Features

### v5.0 - Deep Bloatware Removal

#### Core Debloat
- ✅ **Removes 95+ bloatware apps** - Cortana, Xbox, Bing apps, third-party games
- ✅ **Removes hidden telemetry packages** - 5 obfuscated tracking packages
- ✅ **Complete OneDrive removal** - Uninstalls and cleans up all traces
- ✅ **Enhanced widget removal** - Kills processes, forces removal, prevents reinstall
- ✅ **Keeps essential apps** - Calculator, Notepad, Snipping Tool, Microsoft Store

#### Privacy & Telemetry
- ✅ **Disables Microsoft Copilot** - Removes AI assistant completely
- ✅ **Disables Windows Recall** - Prevents AI screenshot collection
- ✅ **Disables telemetry** - Comprehensive data collection blocking
- ✅ **Disables Content Delivery Manager** - No app suggestions or ads
- ✅ **Disables Windows Spotlight** - Removes desktop "Learn more" button
- ✅ **Blocks 50+ telemetry domains** - via hosts file

#### Services & Tasks
- ✅ **Disables 20+ unnecessary services** - Xbox, maps, retail demo, etc.
- ✅ **Disables 27+ telemetry tasks** - Including Family Safety monitoring
- ✅ **Disables 5 Windows features** - WCF, WorkFolders, Internet Printing

#### Security Hardening
- ✅ **Disables SMBv1** - Prevents WannaCry/NotPetya vulnerabilities
- ✅ **Disables PowerShell v2** - Closes security bypass risks
- ✅ **Enables Remote Desktop (RDP)** - Secure remote access with NLA
- ✅ **Configures Niagara firewall rules** - Allows only secure ports

#### Performance & Power
- ✅ **24/7 power settings** - Never sleep, never hibernate, always-on
- ✅ **High performance power plan** - Optimized for appliance use
- ✅ **Disables Edge auto-launch** - Prevents startup delays
- ✅ **Manual Windows Update** - You control when updates happen

#### Niagara-Specific
- ✅ **Firewall rules for secure Niagara ports**:
  - TCP 443 (HTTPS/Web)
  - TCP 4911 (Foxs Secure)
  - TCP 5011 (Secure Platform)
  - UDP 47808 (BACnet/IP)
- ✅ **Blocks insecure ports**: 80, 1911, 3011
- ✅ **Optional hostname configuration** - Non-blocking with auto-skip

## 📋 What Gets Removed

<details>
<summary><b>Microsoft Bloatware (60+ apps)</b></summary>

- Cortana & Copilot
- Xbox (all components)
- Bing (Weather, News, Sports, Finance, etc.)
- Office Hub, OneNote, Sway
- Mixed Reality Portal
- People, Mail, Calendar
- Your Phone, Phone Link
- Clipchamp, Photos, Camera
- Paint 3D
- Feedback Hub, Tips
- And many more...
</details>

<details>
<summary><b>Third-Party Bloatware (35+ apps)</b></summary>

- Social: Facebook, Instagram, Twitter, TikTok, LinkedIn
- Games: Candy Crush, Asphalt, Disney games, etc.
- Media: Netflix, Spotify, Hulu, Pandora
- Utilities: Adobe Express, Dolby, etc.
</details>

<details>
<summary><b>Hidden Telemetry Packages (5 packages)</b></summary>

- MicrosoftWindows.57242383.Tasbar (Taskbar telemetry)
- MicrosoftWindows.59336768.Speion (Spying/telemetry)
- MicrosoftWindows.59337133.Voiess (Voice services)
- MicrosoftWindows.59337145.Livtop (Live Tiles)
- MicrosoftWindows.59379618.InpApp (Input telemetry)
</details>

## 🎯 Use Case

This script is specifically designed for **Niagara Supervisor appliances** used in building automation systems, where:

- The machine runs 24/7 without user interaction
- Bloatware consumes unnecessary resources
- Telemetry and updates should be controlled
- Security and network configuration are critical
- The system must be lean, stable, and purpose-built

## ⚠️ Prerequisites

- **Windows 11** (any edition)
- **Administrator privileges** (Run as Administrator)
- **Active internet connection** (for downloading, optional after install)

## 🔧 What Happens During Execution

1. **Creates system restore point** (safety first!)
2. **Removes 95+ bloatware apps** (2-3 minutes)
3. **Removes OneDrive** (uninstalls and cleans up)
4. **Enhanced widget removal** (kills processes, prevents reinstall)
5. **Disables telemetry & data collection** (registry + services)
6. **Configures privacy settings** (Content Delivery Manager, Spotlight)
7. **Disables unnecessary services** (20+ services)
8. **Disables scheduled tasks** (27+ telemetry tasks)
9. **Applies security hardening** (SMBv1, PowerShell v2)
10. **Optimizes performance** (24/7 power settings)
11. **Enables Remote Desktop** (RDP with NLA security)
12. **Configures Niagara firewall rules** (secure ports only)
13. **Optional hostname configuration** (with 30-second auto-skip)
14. **Blocks telemetry domains** (via hosts file)

**Total time: ~5 minutes**

## 📊 Results

| Metric | Before | After |
|--------|--------|-------|
| AppX Packages | ~180 | ~90 |
| Running Processes | Higher | Lower |
| Telemetry Services | Active | Disabled |
| Startup Time | Slower | Faster |
| System Responsiveness | Lower | Higher |

**User-visible changes:**
- ✅ No weather widget in taskbar
- ✅ No desktop "Learn more" button
- ✅ No app suggestions in Start Menu
- ✅ No lock screen ads
- ✅ Cleaner, faster system

## 🛡️ Safety Features

- **System Restore Point** - Created before any changes
- **Keeps essential apps** - Calculator, Store, Notepad remain
- **Non-destructive** - No critical Windows components removed
- **Logging** - Full transcript saved to `C:\ProgramData\NiagaraProvisioning\Logs\`
- **Tested** - Validated on production Niagara systems

## 📝 Post-Installation Steps

1. **Reboot the system** (required for all changes to take effect)
2. **Run Windows Update** manually for security patches
3. **Install Niagara Workbench** software
4. **Verify BIOS setting**: "After Power Loss" = "Power On" (for 24/7 operation)
5. **Optional**: Install Tailscale VPN or OpenSSH Server if needed

## 🔍 Validation

After reboot, verify the changes:

```powershell
# Verify widgets removed
Get-Process -Name Widgets -ErrorAction SilentlyContinue  # Should return nothing

# Check remaining packages
(Get-AppxPackage -AllUsers | Measure-Object).Count  # Should be ~90

# Verify Content Delivery Manager disabled
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" |
    Select-Object RotatingLockScreenEnabled, SilentInstalledAppsEnabled  # Should both be 0

# Verify Windows Spotlight disabled
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsSpotlightFeatures |
    Select-Object -ExpandProperty DisableWindowsSpotlightFeatures  # Should be 1
```

## 📖 Documentation

- **Full log location**: `C:\ProgramData\NiagaraProvisioning\Logs\Provision-<hostname>-<timestamp>.log`
- **Changelog**: See [CHANGELOG.md](CHANGELOG.md)
- **License**: See [LICENSE](LICENSE)

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly on a non-production system
4. Submit a pull request with clear description

## ⚖️ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

**Use at your own risk!** This script makes significant changes to Windows:
- Test on a non-production system first
- Review the code before running
- Ensure you have backups
- Some changes may affect other software
- Not officially affiliated with Tridium or Niagara

## 🙏 Acknowledgments

Based on research from:
- [Win11Debloat](https://github.com/Raphire/Win11Debloat)
- [Chris Titus Tech WinUtil](https://github.com/ChrisTitusTech/winutil)
- NIST SP 800-82 (Industrial Control Systems Security)
- Niagara 4 Hardening Guide

Optimized specifically for Niagara building automation supervisors.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/sqrlman-g/niagara-windows11-debloat/issues)
- **Discussions**: [GitHub Discussions](https://github.com/sqrlman-g/niagara-windows11-debloat/discussions)

## 🔗 Related Projects

- [Niagara 4 Documentation](https://www.tridium.com/products-services/niagara4)
- [Windows 11 Debloat Scripts](https://github.com/topics/windows-debloat)

---

**Made with ❤️ for the Niagara building automation community**
