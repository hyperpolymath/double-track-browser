<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Security Policy

## Supported Versions

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 0.1.x   | :white_check_mark: | Active development |
| < 0.1   | :x:                | Pre-release, unsupported |

## Security Model

DoubleTrack Browser is **experimental privacy software** with specific security considerations:

### Threat Model

**In Scope**:
- Privacy data leakage (real browsing data mixed with simulated)
- Storage injection attacks (malicious data in chrome.storage)
- WASM sandbox escapes
- Content script injection vulnerabilities
- Extension permission abuse
- Timing side-channels revealing real vs. simulated activity

**Out of Scope**:
- Physical access attacks
- Browser zero-days (rely on browser vendor patches)
- Social engineering of users
- Cryptographic attacks (we don't use cryptography)

### Security Principles

1. **Data Separation**: Real and simulated browsing must NEVER mix
2. **Local-Only**: No network calls, all data stays on device
3. **Minimal Permissions**: Only request necessary browser APIs
4. **Type Safety**: Rust + TypeScript strict mode prevent classes of bugs
5. **Memory Safety**: Rust ownership model prevents memory corruption
6. **Reversibility**: User can disable and clear all data instantly

## Reporting a Vulnerability

### Critical Vulnerabilities

If you discover a vulnerability that could:
- Leak real user browsing data
- Enable remote code execution
- Bypass browser sandboxing
- Compromise user privacy

**Please report IMMEDIATELY via**:

**Email**: security@example.com (PGP key below)
**Response Time**: Within 48 hours
**Coordinated Disclosure**: 90 days

### Non-Critical Issues

For lower-severity issues:
- Open a **private** GitHub Security Advisory
- Or email: security@example.com

### What to Include

Please provide:
1. **Description**: What is the vulnerability?
2. **Impact**: What can an attacker do?
3. **Reproduction**: Step-by-step PoC
4. **Environment**: Browser, OS, extension version
5. **Suggested Fix** (optional): How to remediate

### Example Report Template

```
## Vulnerability Report

**Title**: [Brief description]

**Severity**: [Critical/High/Medium/Low]

**Description**:
[Detailed explanation of the vulnerability]

**Impact**:
- Privacy: [Yes/No - describe]
- Availability: [Yes/No - describe]
- Integrity: [Yes/No - describe]

**Reproduction Steps**:
1. Install extension version X
2. Enable simulation with profile Y
3. Open developer console
4. Execute: [code/actions]
5. Observe: [vulnerability manifestation]

**Environment**:
- Extension Version: 0.1.0
- Browser: Chrome 120.0.6099.109
- OS: Ubuntu 22.04 LTS

**Suggested Fix** (optional):
[Your recommendation]

**Disclosure Preference**:
- Public credit: [Yes/No]
- Name/handle: [If yes to credit]
```

## Vulnerability Disclosure Process

### Timeline

1. **T+0 hours**: Report received, acknowledge within 48 hours
2. **T+7 days**: Initial assessment and severity classification
3. **T+14 days**: Patch development begins (or explanation if won't fix)
4. **T+30 days**: Patch testing and validation
5. **T+60 days**: Coordinated release (or earlier if urgent)
6. **T+90 days**: Public disclosure (or earlier if exploited in wild)

### Severity Classification

| Severity | SLA | Criteria |
|----------|-----|----------|
| **Critical** | 7 days patch | RCE, data exfiltration, sandbox escape |
| **High** | 30 days patch | Privacy leak, privilege escalation |
| **Medium** | 60 days patch | DoS, logic errors, minor data exposure |
| **Low** | 90 days patch | UI spoofing, minor issues |

### Remediation

Depending on severity:
- **Critical/High**: Emergency release + blog post + CVE
- **Medium**: Regular release + changelog entry
- **Low**: Bundled in next release

## Security Testing

### Automated Testing

We run:
- **Cargo audit** for Rust dependency vulnerabilities
- **npm audit** for JavaScript dependency vulnerabilities
- **TypeScript strict mode** for type safety
- **Rust borrow checker** for memory safety
- **ESLint security rules** for common JS vulnerabilities

### Manual Testing

We encourage:
- Code review of all changes
- WASM sandbox boundary audits
- Storage injection testing
- Permission escalation attempts

### Fuzzing (Future)

Planned:
- cargo-fuzz for Rust core
- WASM boundary fuzzing
- Storage API fuzzing

## Known Issues & Limitations

### Current Limitations (v0.1.0)

1. **WASM Integration Incomplete**: Mock implementations in use
   - **Risk**: Type mismatches could cause runtime errors
   - **Mitigation**: TypeScript strict mode, extensive testing
   - **Timeline**: Full integration by v0.2.0

2. **No Rate Limiting**: Simulated activities could be excessive
   - **Risk**: Resource exhaustion, browser slowdown
   - **Mitigation**: User-configurable noise levels, activity caps
   - **Timeline**: Rate limiting in v0.3.0

3. **Experimental Software**: Not security-audited by third party
   - **Risk**: Unknown vulnerabilities may exist
   - **Mitigation**: Open source for community review
   - **Timeline**: Professional audit planned for v1.0.0

### Design Decisions

**Why no encryption?**
- All data is local-only
- Browser already provides storage encryption
- Adding crypto increases attack surface
- KISS principle

**Why TypeScript instead of Rust for extension?**
- Browser APIs are JavaScript-native
- WASM has limitations with async Chrome APIs
- TypeScript provides sufficient type safety
- Performance not critical for UI

**Why allow activity simulation at all?**
- Core feature of the extension
- User explicitly enables it
- Activities are sandboxed (no actual tab opening by default)
- Reversible (can clear all data)

## Security Features

### Data Protection

- **Storage Isolation**: chrome.storage.local (per-extension isolation)
- **No External Calls**: Zero network requests, fully offline
- **Type Safety**: Rust + TypeScript prevent injection
- **Memory Safety**: Rust ownership prevents corruption

### Runtime Protection

- **Content Security Policy**: Restrictive CSP in manifest
- **Sandboxed WASM**: No direct system access
- **Permission Minimization**: Only required APIs
- **User Consent**: Explicit enable required

### Auditability

- **Open Source**: All code public on GitHub
- **Reproducible Builds**: Deterministic compilation (planned)
- **Signed Releases**: GPG signatures (planned)
- **Build Provenance**: SLSA attestation (planned)

## Security Resources

### For Users

- [Privacy Policy](docs/PRIVACY.md) (TODO)
- [User Security Guide](docs/USER_SECURITY.md) (TODO)
- [FAQ](README.md#faq)

### For Developers

- [Secure Coding Guidelines](CONTRIBUTING.md#security)
- [Threat Model](docs/THREAT_MODEL.md) (TODO)
- [Security Architecture](docs/ARCHITECTURE.md) (TODO)

### External Resources

- [OWASP Browser Extension Security](https://cheatsheetseries.owasp.org/cheatsheets/Browser_Extension_Security_Cheat_Sheet.html)
- [Chrome Extension Security Best Practices](https://developer.chrome.com/docs/extensions/mv3/security/)
- [WebAssembly Security](https://webassembly.org/docs/security/)

## PGP Key

```
-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: DoubleTrack Browser Security Team
Comment: security@example.com

[TODO: Add actual PGP public key]

-----END PGP PUBLIC KEY BLOCK-----
```

## Hall of Fame

We gratefully acknowledge security researchers who responsibly disclose vulnerabilities:

| Researcher | Vulnerability | Severity | Date | Bounty |
|------------|---------------|----------|------|--------|
| *None yet* | - | - | - | - |

**Note**: We currently do not offer monetary bounties but will provide:
- Public credit (if desired)
- Acknowledgment in release notes
- Co-authorship credit for significant findings
- Eternal gratitude and good karma

## Contact

- **Security Email**: security@example.com
- **GPG Fingerprint**: [TODO]
- **Security Advisory**: https://github.com/yourusername/double-track-browser/security/advisories
- **Response SLA**: 48 hours

---

**Last Updated**: 2025-11-22
**Version**: 1.0
**Next Review**: 2026-05-22 (6 months)
