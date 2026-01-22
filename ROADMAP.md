# Roadmap & Future Enhancements

This document tracks planned features, improvements, and ideas for future versions of the Windows 11 Niagara Debloat Script.

## 🎯 Planned for v6.0

### 1. Tailscale Auto-Installation & Configuration
**Priority: High**

Automatically download, install, and configure Tailscale VPN for secure remote access.

**Features:**
- Download official Tailscale MSI from `https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi`
- Silent install: `msiexec /i tailscale-setup.msi /quiet /qn`
- Auto-authenticate with auth key (configurable)
- Auto-tagging: `tag:niagara`, `tag:supervisor`, `tag:site-{location}`
- Set to auto-start on boot (Windows service)
- Enable auto-updates
- Optional: Advertise as subnet router for BACnet networks

**Configuration options:**
```powershell
$TailscaleConfig = @{
    AuthKey = "tskey-auth-xxxxx"  # From environment variable or config file
    Tags = @("tag:niagara", "tag:supervisor", "tag:production")
    AcceptRoutes = $true
    AdvertiseRoutes = ""  # e.g., "192.168.1.0/24" for BACnet subnet
    ExitNode = ""  # Optional exit node
    Hostname = $env:COMPUTERNAME  # Or custom name
}
```

**Benefits:**
- Secure remote access without VPN client on technician machines
- Zero-touch deployment
- Centralized access control via Tailscale ACLs
- No port forwarding needed

**Challenges:**
- Need secure way to provide auth key (environment variable, config file, or interactive prompt)
- Auth key management (reusable vs one-time)

---

### 2. Niagara Workbench Auto-Download
**Priority: High**

Download Niagara Workbench installer from self-hosted repository.

**Features:**
- Download from private/self-hosted repo (URL configurable)
- Support authentication (API key, basic auth, or pre-signed URLs)
- Verify file hash/checksum for security
- Optional: Silent install of Niagara Workbench
- Version selection (latest, specific version, or latest LTS)

**Configuration options:**
```powershell
$NiagaraConfig = @{
    RepoUrl = "https://your-server.com/downloads/niagara"  # Or S3, Azure Blob, etc.
    Version = "latest"  # or "4.13.0.123"
    AuthMethod = "apikey"  # or "basic", "none"
    ApiKey = $env:NIAGARA_DOWNLOAD_KEY
    InstallPath = "C:\Niagara"
    SilentInstall = $true
}
```

**Download sources:**
- Self-hosted web server (nginx, Apache)
- Cloud storage (S3, Azure Blob, Google Cloud Storage with pre-signed URLs)
- Internal file share (SMB/CIFS)
- Git LFS repository

**Benefits:**
- Fully automated deployment
- No manual downloads needed
- Version control
- Faster onsite provisioning

**Challenges:**
- Need secure credential management
- Large file downloads (handle network interruptions)
- License activation (may need to be manual)

---

### 3. Configuration File Support
**Priority: Medium**

Load settings from a JSON/YAML configuration file instead of hardcoding.

**Example: `niagara-config.json`**
```json
{
  "version": "6.0",
  "hostname": {
    "enabled": true,
    "format": "{location}-NIAG-{number}",
    "location": "DOWNS",
    "number": "01"
  },
  "tailscale": {
    "enabled": true,
    "authKey": "${env:TAILSCALE_AUTH_KEY}",
    "tags": ["tag:niagara", "tag:supervisor", "tag:site-downs"],
    "acceptRoutes": true,
    "advertiseRoutes": "192.168.1.0/24"
  },
  "niagara": {
    "enabled": true,
    "repoUrl": "https://downloads.example.com/niagara",
    "version": "latest",
    "apiKey": "${env:NIAGARA_API_KEY}",
    "silentInstall": true
  },
  "firewall": {
    "niagaraPorts": [443, 4911, 5011],
    "bacnetEnabled": true,
    "blockInsecure": true
  },
  "customizations": {
    "removePhotoApp": true,
    "removeCameraApp": true,
    "keep24x7Power": true
  }
}
```

**Benefits:**
- Easy customization per site/customer
- No script editing required
- Version control for configurations
- Template configurations for different deployment scenarios

---

## 🚀 Enhancement Ideas

### 4. Site-Specific Profiles
**Priority: Medium**

Pre-configured profiles for different deployment scenarios.

**Profiles:**
- `minimal` - Essential debloat only, keep more apps
- `standard` - Current v5.0 behavior (recommended)
- `aggressive` - Remove even more (e.g., Edge, Defender exclusions)
- `industrial` - Optimized for OT/ICS environments (max security)
- `test` - For test/lab systems (keep more debugging tools)

**Usage:**
```powershell
.\windows11-niagara-debloat.ps1 -Profile "standard"
```

---

### 5. Network Configuration Automation
**Priority: Low**

Configure static IP, DNS, NTP for Niagara supervisors.

**Features:**
- Set static IP address (via config file)
- Configure DNS servers (Google, Cloudflare, or custom)
- Set NTP servers for time sync (critical for BACnet)
- Configure network adapter settings (disable IPv6, etc.)

**Example config:**
```json
{
  "network": {
    "interface": "Ethernet",
    "ipAddress": "192.168.1.100",
    "subnetMask": "255.255.255.0",
    "gateway": "192.168.1.1",
    "dns": ["192.168.1.1", "8.8.8.8"],
    "ntp": ["time.nist.gov", "pool.ntp.org"]
  }
}
```

---

### 6. Pre-Install Validation & System Check
**Priority: Medium**

Check system requirements before running debloat script.

**Checks:**
- Windows 11 version (minimum build)
- Disk space available
- Network connectivity
- Admin privileges (already done)
- BIOS/UEFI settings recommendations
- Hardware compatibility (CPU, RAM, disk type)

**Example output:**
```
[Pre-Flight Check]
✓ Windows 11 Pro (Build 22631)
✓ 256 GB free disk space
✓ Network connectivity
✓ Administrator privileges
⚠ BIOS: "After Power Loss" not set to "Power On" (recommended for 24/7 operation)
✓ TPM 2.0 enabled
```

---

### 7. Post-Install Verification Script
**Priority: Medium**

Separate script to verify all changes were applied correctly.

**Checks:**
- Bloatware packages removed (count)
- Services disabled
- Scheduled tasks disabled
- Registry keys set correctly
- Firewall rules configured
- Power settings correct
- Tailscale connected (if installed)
- Niagara Workbench installed (if installed)

**Usage:**
```powershell
.\verify-debloat.ps1
```

**Output:**
```
[Verification Report]
✓ 90 AppX packages remaining (expected: ~90)
✓ Widgets.exe not running
✓ Content Delivery Manager disabled
✓ Windows Spotlight disabled
✓ 20 services disabled
✓ 27 scheduled tasks disabled
✓ Firewall rules configured (5 rules)
✓ Power plan: High Performance (24/7 settings)
✓ Tailscale connected: 100.64.1.50
⚠ Niagara Workbench not detected

Overall Score: 95% (19/20 checks passed)
```

---

### 8. Rollback/Undo Script
**Priority: Low**

Script to reverse changes if needed.

**Features:**
- Restore from System Restore Point (created by debloat script)
- Re-enable specific services
- Re-install specific apps from Microsoft Store
- Reset registry keys

---

### 9. Multi-Machine Deployment Tool
**Priority: Low**

Deploy to multiple supervisors at once.

**Features:**
- Read list of machines from CSV file
- SSH/WinRM to each machine
- Run debloat script remotely
- Collect logs from all machines
- Generate summary report

**Example CSV:**
```csv
Hostname,IP,Location,TailscaleTag
DOWNS-NIAG-01,192.168.1.100,DownsSup,tag:site-downs
SMITH-NIAG-01,192.168.2.100,SmithBuilding,tag:site-smith
```

**Usage:**
```powershell
.\deploy-multiple.ps1 -MachineList machines.csv -ConfigFile niagara-config.json
```

---

### 10. Windows Update Control
**Priority: Low**

More granular Windows Update control.

**Features:**
- Block specific updates (by KB number)
- Auto-install security updates only
- Schedule update windows (e.g., weekends only)
- Defer feature updates (stay on current version longer)
- Group Policy configuration

---

### 11. Logging & Monitoring Integration
**Priority: Low**

Send logs to central logging system.

**Features:**
- Send transcript logs to syslog server
- Integration with Splunk, ELK, Graylog
- Email summary reports
- Webhook notifications (Slack, Teams, Discord)

---

## 🛠️ Technical Improvements

### 12. Idempotency
**Priority: High**

Make script safe to run multiple times.

**Features:**
- Skip already-removed packages
- Don't fail if service already disabled
- Check before creating firewall rules
- Update rather than re-create

**Benefits:**
- Can re-run after Windows Updates
- Safe for maintenance/updates
- Can add new features without re-doing old work

---

### 13. Modular Architecture
**Priority: Medium**

Break script into modules for easier maintenance.

**Structure:**
```
modules/
├── Remove-Bloatware.ps1
├── Disable-Telemetry.ps1
├── Configure-Firewall.ps1
├── Install-Tailscale.ps1
├── Install-Niagara.ps1
└── Set-PowerSettings.ps1
```

**Benefits:**
- Easier testing
- Can run individual modules
- Better code organization
- Community contributions easier

---

### 14. Error Handling & Recovery
**Priority: Medium**

Improve error handling and recovery.

**Features:**
- Catch and log all errors
- Continue on non-critical errors
- Rollback on critical failures
- Retry logic for network operations
- Clear error messages with remediation steps

---

### 15. Progress Bar & Better UX
**Priority: Low**

Improve visual feedback during execution.

**Features:**
- Progress bar for long operations
- Estimated time remaining
- Section-by-section progress (already done with [X/13])
- Color-coded output (already done)
- Summary at the end with what changed

---

## 📚 Documentation Improvements

### 16. Video Tutorial
**Priority: Low**

Create video walkthrough of installation and validation.

---

### 17. FAQ Document
**Priority: Medium**

Common questions and troubleshooting.

**Topics:**
- What apps are safe to remove?
- How to re-install removed apps?
- How to customize the script?
- What if something breaks?
- Compatibility with Windows 11 versions

---

### 18. Architecture Diagram
**Priority: Low**

Visual diagram showing what the script does.

---

## 🔒 Security Enhancements

### 19. Code Signing
**Priority: Medium**

Sign the PowerShell script with a code signing certificate.

**Benefits:**
- Users can verify authenticity
- Can run without `-ExecutionPolicy Bypass`
- Better trust model

---

### 20. Checksum Verification
**Priority: Medium**

Provide SHA256 checksums for all releases.

**Example:**
```
windows11-niagara-debloat.ps1
SHA256: a1b2c3d4e5f6...
```

---

## 🧪 Testing & Quality

### 21. Automated Testing
**Priority: Medium**

Pester tests for PowerShell script.

**Tests:**
- Syntax validation
- Function unit tests
- Integration tests (in VM)
- Regression tests

---

### 22. CI/CD Pipeline
**Priority: Low**

GitHub Actions workflow for automated testing and releases.

**Workflow:**
1. Run Pester tests on commit
2. Run script in Windows 11 VM
3. Validate all changes applied
4. Create GitHub release with changelog
5. Update README with latest version

---

## 📊 Metrics & Analytics

### 23. Usage Analytics (Optional, Opt-In)
**Priority: Low**

Anonymous usage statistics to improve script.

**Metrics:**
- Windows version distribution
- Script version usage
- Features most used
- Common errors encountered
- Average execution time

**Privacy:**
- Completely optional (opt-in)
- No PII collected
- Anonymous machine ID only
- Can be disabled in config

---

## 🌍 Internationalization

### 24. Multi-Language Support
**Priority: Very Low**

Support languages other than English.

---

## 💡 Community Features

### 25. Plugin System
**Priority: Very Low**

Allow community plugins for custom features.

---

## 📅 Release Schedule

### Version 6.0 (Q2 2026)
- Tailscale auto-installation
- Niagara Workbench download
- Configuration file support
- Idempotency improvements

### Version 6.1 (Q3 2026)
- Site-specific profiles
- Pre-install validation
- Post-install verification script

### Version 7.0 (Q4 2026)
- Modular architecture refactor
- Multi-machine deployment
- Network configuration automation

---

## 🤝 Contributing

Want to help implement these features? See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📝 Notes for Future Development

### Current Architecture Decisions

1. **Single-file script** - Easy to distribute, but harder to maintain as it grows
   - Consider modular approach for v7.0

2. **No external dependencies** - Script runs on vanilla Windows 11
   - Keep this for core functionality
   - Optional features (Tailscale, Niagara) can have dependencies

3. **Registry-based configuration** - All settings stored in Windows registry
   - Consider config file for easier management

4. **Silent by default** - Minimal user interaction
   - Keep for automation, add verbose mode for debugging

5. **Logging to file** - Transcript saved to `C:\ProgramData\NiagaraProvisioning\Logs\`
   - Consider centralized logging for enterprise deployments

### Key Considerations

- **Backward Compatibility** - Don't break existing deployments
- **Security First** - Always validate downloads, use HTTPS, verify checksums
- **Fail-Safe** - System Restore Point before any changes
- **Documentation** - Every feature needs clear documentation
- **Testing** - Test on clean Windows 11 VMs before releasing

### Configuration File Location Priority

When implemented, search in this order:
1. `.\niagara-config.json` (same directory as script)
2. `C:\ProgramData\NiagaraProvisioning\niagara-config.json`
3. `%USERPROFILE%\niagara-config.json`
4. Use defaults if none found

### Environment Variables for Secrets

Sensitive data (API keys, auth tokens) should use environment variables:
- `TAILSCALE_AUTH_KEY` - Tailscale authentication key
- `NIAGARA_API_KEY` - Niagara download repository API key
- `NIAGARA_DOWNLOAD_URL` - Custom download URL

Set via:
```powershell
[System.Environment]::SetEnvironmentVariable('TAILSCALE_AUTH_KEY', 'tskey-auth-xxxxx', 'Machine')
```

---

**Last Updated:** 2026-01-22
**Maintained By:** sqrlman-g
