# Changelog

## [0.0.5] - 2025-09-08
### Added
- `Start-CISM365Audit` orchestration to run initial controls.
- New controls under `Private/Controls/`:
  - 1.1.3, 1.2.1, 1.3.1 (initial batch)
- `Connect-CISM365Services` and `Disconnect-CISM365Services` with prompt for SharePoint tenant short name.

### Changed
- Restructured module layout: `Public/` and `Private/` (with `Controls/`).
- Updated `.psd1/.psm1` to align with PS7+ only.

### Fixed
- Early packaging/versioning cleanup.

## [0.0.4] - 2025-09-04
### Added
- MFA control now uses **Microsoft Graph Authentication Methods Usage Insights** for more accurate MFA registration checks.
- Cross-platform DMARC check: falls back to `nslookup` or `dig` when `Resolve-DnsName` is unavailable.
- HTML report improvements:
  - Proper link rendering with safe encoding.
  - Added `rel="noopener noreferrer"` for security.

### Changed
- `Disconnect-CISM365Services` now accepts `SharePoint` and `Compliance` synonyms and normalizes them to `SharePointOnline` and `Purview` for compatibility with `Connect-CISM365Services -ForceReauth`.
- Improved HTML encoding for descriptions and rationales in reports.
- Minor UX tweaks for verbose output and error handling.

### Fixed
- Resolved quoting issue in HTML link generation that caused runtime errors.
- Ensured `ForceReauth` works consistently across Connect/Disconnect functions.

### Known Limitations
- MFA enforcement still requires manual review; current check validates registration only.
- DMARC check requires DNS resolution; returns `MANUAL` if DNS tools are unavailable.

---
