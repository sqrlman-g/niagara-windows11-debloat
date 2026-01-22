# TODO - Immediate Next Steps

Quick reference for immediate tasks and future work.

## 🔥 High Priority (Next Session)

### v6.0 Core Features

- [ ] **Tailscale Auto-Install**
  - [ ] Download MSI from official Tailscale CDN
  - [ ] Silent install with msiexec
  - [ ] Auto-authenticate with auth key (from env var or config)
  - [ ] Set tags: `tag:niagara`, `tag:supervisor`, `tag:site-{location}`
  - [ ] Verify service auto-starts on boot
  - [ ] Test on downssup machine

- [ ] **Niagara Workbench Download**
  - [ ] Determine hosting solution (S3, Azure Blob, self-hosted web server)
  - [ ] Implement secure download (API key or pre-signed URL)
  - [ ] Add SHA256 checksum verification
  - [ ] Optional silent install
  - [ ] Test with actual Niagara installer

- [ ] **Configuration File Support**
  - [ ] Create JSON schema for config file
  - [ ] Implement config file parser
  - [ ] Support environment variable substitution
  - [ ] Add `-ConfigFile` parameter to script
  - [ ] Create example config templates

- [ ] **Make Script Idempotent**
  - [ ] Check if packages already removed before attempting removal
  - [ ] Check if services already disabled
  - [ ] Check if registry keys already set
  - [ ] Safe to run multiple times

## 📋 Medium Priority

- [ ] **Post-Install Verification Script**
  - [ ] Create `verify-debloat.ps1`
  - [ ] Check all debloat actions applied
  - [ ] Generate verification report
  - [ ] Score system (X/Y checks passed)

- [ ] **Pre-Flight System Check**
  - [ ] Verify Windows 11 minimum build
  - [ ] Check available disk space (minimum 20 GB free)
  - [ ] Verify network connectivity
  - [ ] Check BIOS settings recommendations

- [ ] **Site Profiles**
  - [ ] Create profile system (`-Profile` parameter)
  - [ ] Profiles: minimal, standard, aggressive, industrial
  - [ ] Profile config files in `profiles/` directory

- [ ] **Error Handling Improvements**
  - [ ] Better error messages with remediation steps
  - [ ] Retry logic for network operations
  - [ ] Continue on non-critical errors
  - [ ] Rollback on critical failures

## 🎨 Nice to Have

- [ ] **Documentation**
  - [ ] Add FAQ.md
  - [ ] Create troubleshooting guide
  - [ ] Record video walkthrough
  - [ ] Architecture diagram

- [ ] **GitHub Repository Enhancements**
  - [ ] Add repository topics/tags
  - [ ] Create issue templates
  - [ ] Add pull request template
  - [ ] Create CONTRIBUTING.md
  - [ ] Add GitHub Actions CI/CD

- [ ] **Code Improvements**
  - [ ] Add progress bar for long operations
  - [ ] Modular architecture (split into modules)
  - [ ] Pester unit tests
  - [ ] Code signing certificate

## 🐛 Known Issues / Tech Debt

- [ ] Line ending warnings from Git (CRLF vs LF) - not critical
- [ ] Some packages in the removal list may not exist on all systems (handled gracefully)
- [ ] Hostname prompt timeout uses job - could be more elegant
- [ ] No way to customize bloatware list without editing script (need config file)

## 📝 Documentation Updates Needed

- [ ] Update README with v6.0 features when ready
- [ ] Document configuration file format
- [ ] Add Tailscale setup guide
- [ ] Add Niagara hosting guide

## 🧪 Testing Checklist (Before v6.0 Release)

- [ ] Test on clean Windows 11 Pro VM
- [ ] Test on Windows 11 Home VM
- [ ] Test with Tailscale installation
- [ ] Test with Niagara download
- [ ] Test config file loading
- [ ] Test idempotency (run twice, verify no errors)
- [ ] Test on downssup production machine
- [ ] Verify all v5.0 features still work

## 💡 Ideas to Consider

- [ ] Multi-machine deployment script (SSH to list of IPs)
- [ ] Ansible playbook for large deployments
- [ ] Docker container for testing
- [ ] Web-based configuration generator
- [ ] Windows Update deferral policies
- [ ] Centralized logging (syslog, Splunk, ELK)
- [ ] Slack/Teams webhook notifications

## 🔒 Security TODO

- [ ] Code signing certificate for script
- [ ] SHA256 checksums for releases
- [ ] Security audit of script
- [ ] Document security considerations
- [ ] Secure credential storage guide

## 🌐 Repository Maintenance

- [ ] Create GitHub release for v5.0
- [ ] Add CHANGELOG to releases
- [ ] Create release notes
- [ ] Set up GitHub Discussions
- [ ] Monitor issues and respond

---

## Quick Commands for Development

```bash
# Navigate to repo
cd C:\Users\cavin\code\niagara-windows11-debloat

# Check status
git status

# Test script locally
powershell -ExecutionPolicy Bypass -File .\windows11-niagara-debloat.ps1

# Test on remote machine
scp -i ~/.ssh/id_ed25519_niagara_test windows11-niagara-debloat.ps1 downshvac@downssup:C:\Users\downshvac\Downloads\
ssh -i ~/.ssh/id_ed25519_niagara_test downshvac@downssup "powershell -ExecutionPolicy Bypass -File C:\Users\downshvac\Downloads\windows11-niagara-debloat.ps1"

# Commit and push changes
git add .
git commit -m "Description of changes"
git push

# Create new release
gh release create v6.0.0 --title "v6.0 - Tailscale & Niagara Auto-Install" --notes "Release notes here"
```

---

**Last Updated:** 2026-01-22
