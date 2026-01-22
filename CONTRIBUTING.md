# Contributing to Windows 11 Niagara Debloat

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## 🤝 How to Contribute

### Reporting Issues

- **Search existing issues** first to avoid duplicates
- **Use issue templates** when creating new issues
- **Provide details**: Windows version, script version, error messages, logs
- **Include logs** from `C:\ProgramData\NiagaraProvisioning\Logs\`

### Suggesting Features

- Check the [ROADMAP.md](ROADMAP.md) to see if it's already planned
- Open an issue with the `enhancement` label
- Describe the use case and expected behavior
- Consider implementation complexity and maintenance burden

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/my-feature`
3. **Make your changes**
4. **Test thoroughly** (see Testing section below)
5. **Update documentation** (README, CHANGELOG, etc.)
6. **Commit with clear messages** (see Commit Messages below)
7. **Push to your fork**: `git push origin feature/my-feature`
8. **Open a Pull Request** against `main` branch

## 📝 Development Guidelines

### Code Style

- **PowerShell style**: Follow [PowerShell Practice and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)
- **Indentation**: 4 spaces (no tabs)
- **Line length**: Prefer <120 characters
- **Comments**: Explain "why", not "what"
- **Function names**: Use PowerShell verb-noun format (`Get-`, `Set-`, `Remove-`, etc.)

### Script Structure

```powershell
# Section header with consistent formatting
# ============================================
# SECTION X: Description
# ============================================
Write-Host "[X/Y] Section description..." -ForegroundColor Yellow

# Implementation
try {
    # Code here
    Write-Host "  ✓ Action completed" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Action failed: $_" -ForegroundColor Red
}

Write-Host "  Done with section." -ForegroundColor Green
```

### Error Handling

- **Catch errors**: Use try/catch for operations that can fail
- **Continue on non-critical errors**: Use `-ErrorAction SilentlyContinue` where appropriate
- **Log errors**: Include error details in output
- **Provide context**: Help users understand what went wrong

### Testing

Before submitting a PR, test your changes:

1. **Syntax check**:
   ```powershell
   Get-Command .\windows11-niagara-debloat.ps1
   ```

2. **Run on clean Windows 11 VM**:
   - Create a snapshot before running
   - Test both Pro and Home editions if possible
   - Verify all changes applied correctly

3. **Test idempotency** (run twice):
   ```powershell
   # First run
   .\windows11-niagara-debloat.ps1

   # Second run - should not fail
   .\windows11-niagara-debloat.ps1
   ```

4. **Verify logs**: Check transcript log for errors

5. **Test on production-like system** (if possible)

### Documentation

Update documentation when making changes:

- **README.md**: User-facing changes (features, installation, usage)
- **CHANGELOG.md**: All changes (features, fixes, breaking changes)
- **ROADMAP.md**: Remove completed items, add new ideas
- **Code comments**: Complex logic, workarounds, or non-obvious behavior

## 📋 Commit Messages

Use clear, descriptive commit messages:

### Format

```
<type>: <short summary>

<optional detailed description>

<optional footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build, etc.)

### Examples

```
feat: Add Tailscale auto-installation

- Downloads official MSI from Tailscale CDN
- Silent install with authentication key
- Auto-tags machines with tag:niagara
- Configures auto-start on boot

Closes #42
```

```
fix: Hostname prompt now times out in non-interactive sessions

Previously, the script would hang when run via SSH without a TTY.
Now implements a 30-second timeout using PowerShell jobs.

Fixes #38
```

```
docs: Update README with v6.0 features
```

## 🧪 Testing Requirements

### Minimum Testing

- ✅ Script runs without syntax errors
- ✅ No breaking changes to existing functionality
- ✅ Logs are generated correctly
- ✅ System Restore Point is created
- ✅ Script completes all sections

### Recommended Testing

- Test on multiple Windows 11 builds (22000, 22621, 22631, etc.)
- Test on both Pro and Home editions
- Test in VM and physical hardware
- Test with and without internet connection (for offline scenarios)
- Verify changes persist after reboot

### Integration Testing

For features that integrate with external services (Tailscale, Niagara):

- Test with valid credentials
- Test with invalid credentials (should fail gracefully)
- Test network interruptions (retry logic)
- Test on slow connections

## 🔒 Security Considerations

### Important Rules

- **Never commit secrets**: API keys, passwords, tokens
- **Validate all input**: User input, config files, downloads
- **Use HTTPS**: All downloads from the internet
- **Verify checksums**: For downloaded files (SHA256)
- **Principle of least privilege**: Only request permissions needed
- **Document security implications**: In PRs and documentation

### Security Review Checklist

Before submitting security-sensitive changes:

- [ ] No hardcoded credentials
- [ ] Input validation implemented
- [ ] HTTPS used for downloads
- [ ] Checksums verified for downloads
- [ ] No arbitrary code execution from user input
- [ ] Registry changes documented
- [ ] Service changes documented

## 📦 Release Process

Releases are managed by maintainers. Contributors can suggest releases.

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **Major (X.0.0)**: Breaking changes, major refactors
- **Minor (x.Y.0)**: New features, backward compatible
- **Patch (x.y.Z)**: Bug fixes, minor improvements

### Release Steps (Maintainers)

1. Update `CHANGELOG.md`
2. Update version in script header comments
3. Create Git tag: `git tag -a v6.0.0 -m "v6.0 - Tailscale & Niagara Auto-Install"`
4. Push tag: `git push origin v6.0.0`
5. Create GitHub release with changelog
6. Announce in Discussions/Issues

## 🌟 Recognition

Contributors will be:

- Listed in GitHub contributors page
- Mentioned in release notes (if significant contribution)
- Thanked in project acknowledgments

## ❓ Questions?

- **Open an issue** for clarification
- **Check existing issues/discussions** first
- **Be patient** - maintainers respond as time allows

## 📜 Code of Conduct

### Be Respectful

- Treat all contributors with respect
- Welcome newcomers and be patient
- Constructive criticism is welcome, personal attacks are not
- Focus on the problem, not the person

### Be Professional

- Keep discussions on-topic
- Use clear, professional language
- Provide evidence for claims
- Be open to feedback

### Be Collaborative

- Help others when you can
- Share knowledge and expertise
- Credit others for their work
- Work together toward common goals

## 🙏 Thank You!

Your contributions help make this project better for the entire Niagara community. Whether you're reporting bugs, suggesting features, improving documentation, or contributing code - thank you!

---

**Questions or need help?** Open an issue or discussion on GitHub.
