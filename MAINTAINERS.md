<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Maintainers

This document lists the individuals responsible for the DoubleTrack Browser project and defines the governance structure.

## Current Maintainers

### Core Stewards (Perimeter 1)

| Name | Role | GitHub | Email | Areas | Since |
|------|------|--------|-------|-------|-------|
| [Your Name] | Lead Maintainer | @yourusername | you@example.com | All | 2025-11 |

**Responsibilities**:
- Final decision authority on project direction
- Security incident response
- Release management
- Community moderation
- TPCF perimeter management

### Trusted Contributors (Perimeter 2)

*None currently - perimeter not yet activated*

**Path to Perimeter 2**:
1. Sustained contributions over 3+ months
2. 10+ merged PRs of substance
3. Active participation in discussions
4. Demonstrated understanding of project goals
5. Nomination by existing P1 steward
6. Unanimous approval by all P1 stewards

**Responsibilities** (when activated):
- Code review privileges
- Triage issues and PRs
- Mentor newcomers
- Shape project roadmap

## Governance Model

### Decision-Making Process

**Type A: Routine Decisions** (bugs, docs, refactoring)
- Any maintainer can merge after review
- 24-hour minimum for review window
- LGTM from one P1 steward required

**Type B: Feature Decisions** (new capabilities, API changes)
- Discussion in GitHub issue first
- 72-hour minimum discussion period
- LGTM from majority of P1 stewards
- Lead maintainer has veto power

**Type C: Governance Decisions** (CoC, license, TPCF changes)
- Public RFC process required
- 2-week minimum discussion period
- Unanimous approval by all P1 stewards
- Community input strongly considered

### Conflict Resolution

1. **Direct Communication**: Parties attempt to resolve privately
2. **Mediation**: Neutral P1 steward mediates if needed
3. **Lead Decision**: Lead maintainer makes final call if unresolved
4. **Fork Option**: Dissenting parties may fork under MIT terms

### Succession Planning

**If Lead Maintainer Steps Down**:
1. 30-day notice preferred (not required)
2. Existing P1 stewards elect new lead
3. If no P1 stewards remain, most senior P2 contributor promoted
4. If project abandoned, MIT license permits forking

**Adding New Core Stewards**:
- Requires unanimous approval of existing P1 stewards
- Minimum 12 months as P2 contributor
- Demonstrated commitment to project values
- Invitation-only, not requested

## Perimeter Management

### Current Status: Perimeter 3 Only

**Rationale**: Project is in initial development phase. TPCF Perimeters 1 and 2 are designed but not yet activated. All contributors currently operate in Perimeter 3 (Community Sandbox).

### Activation Criteria

**Perimeter 2 Activation Triggers**:
- Project has 50+ stars on GitHub
- 10+ external contributors
- 100+ merged PRs
- First stable release (v1.0.0)

**Perimeter 1 Expansion Triggers**:
- Project has 500+ stars on GitHub
- 3+ sustained P2 contributors (12+ months)
- Security audit completed
- Lead maintainer needs delegation

## Time Commitments

### Expected Availability

**P1 Stewards**:
- Check GitHub 2-3x per week minimum
- Respond to security issues within 48 hours
- Review PRs within 1 week
- Participate in monthly sync (when P2 activated)

**P2 Contributors** (when activated):
- Check GitHub 1x per week
- Review assigned PRs within 2 weeks
- Optional participation in discussions

### Stepping Down

Maintainers may step down at any time by:
1. Notifying other maintainers (private or public)
2. Opening a PR to remove themselves from this file
3. No justification required

**Emeritus Status**: Former maintainers are honored in CONTRIBUTORS.md (when created) and retain community respect.

## Contact Information

### Public Channels

- **GitHub Issues**: https://github.com/yourusername/double-track-browser/issues
- **Discussions**: https://github.com/yourusername/double-track-browser/discussions
- **Email**: maintainers@example.com (public list)

### Private Channels

- **Security**: security@example.com (see SECURITY.md)
- **Code of Conduct**: conduct@example.com (see CODE_OF_CONDUCT.md)
- **Governance**: governance@example.com (for TPCF perimeter requests)

## Responsibilities

### What Maintainers Do

✅ **Do**:
- Review and merge pull requests
- Triage and respond to issues
- Maintain project infrastructure
- Coordinate releases
- Enforce Code of Conduct
- Protect user privacy
- Foster welcoming community

❌ **Don't**:
- Guarantee response times (best effort only)
- Provide free consulting
- Owe anyone explanations for decisions
- Sacrifice mental health for the project

### What Contributors Should Expect

**You Can Expect**:
- Respectful, professional communication
- Fair review of contributions
- Transparency in decision-making
- Adherence to Code of Conduct
- Acknowledgment in release notes

**You Should Not Expect**:
- Immediate responses
- Acceptance of all PRs
- Custom features on demand
- Detailed justifications for every decision
- Unpaid labor from maintainers

## Maintainer Onboarding (Future)

When promoting to P2 or P1:

1. **Access Grants**:
   - GitHub team membership
   - NPM publish rights (P1 only)
   - Signing keys for releases (P1 only)
   - Email list access

2. **Knowledge Transfer**:
   - Read all documentation
   - Shadow current maintainer for 1 month
   - Pair on 3+ PR reviews
   - Learn release process

3. **First Tasks**:
   - Update MAINTAINERS.md (this file)
   - Introduce yourself in Discussions
   - Set up GPG signing key
   - Review CONTRIBUTING.md

## Recognition

Maintainers volunteer their time and expertise. The community thanks them by:
- Being respectful and patient
- Following contribution guidelines
- Helping other users
- Spreading the word about the project
- Sending encouraging messages
- Buying them coffee ☕ (optional): [TODO: Sponsor link]

## Amendment Process

This document is a living guide and may be updated by:
1. Opening a PR with proposed changes
2. Discussion period of 1 week minimum
3. Approval by majority of P1 stewards
4. Merge and announce in release notes

---

**Version**: 1.0
**Last Updated**: 2025-11-22
**Next Review**: 2026-05-22 (6 months)

---

Thank you to all current and future maintainers for your stewardship! 🙏
