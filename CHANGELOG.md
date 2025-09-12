# Changelog

All notable changes to this project are documented in this file.

## [0.0.8] - 2025-09-12
### Added
- New controls under `Private/Controls/`:
  - More controls in each section

### Updated
- Implemented PowerShell Graph SDK

## [0.0.7] - 2025-09-11
### Added
- New controls under `Private/Controls/`:
  - 2.x.x, 3.x.x, 4.x.x, 5.x.x, 6.x.x, 7.x.x, 8.x.x, 9.x.x (initial batch)

### Updated
- Report layout

## [0.0.6] - 2025-09-08
### Added
- Centralized Connect-CISM365Services helper that accepts a flexible set of service identifiers and common splatted parameters (Tenant, TenantId, TenantDomain, Credential, ErrorOnFailure). This prevents parameter-binding errors when the runner splats connection parameters.
- Start-CISM365Audit aggregation of required services from discovered controls and single-point invocation of Connect-CISM365Services prior to executing controls.
- Lean automatic interactive sign-in behavior:
  - When controls request `Services = @('Graph')`, Connect-CISM365Services will attempt `Connect-MgGraph` if Microsoft.Graph cmdlets are available and no active context exists.
  - When controls request `Services = @('ExchangeOnline')`, Connect-CISM365Services will attempt `Connect-ExchangeOnline` if the ExchangeOnlineManagement module is available and no active session exists.
- Controls updated to be session-preserving:
  - Controls that rely on Microsoft Graph (example: Control.1.1.1.CloudOnlyAdmins) now check for the Microsoft Graph PowerShell SDK and an active context (`Get-MgContext`) and return a `MANUAL` result with clear remediation if no session exists, rather than attempting sign-in themselves.
- Connect-CISM365Services now maps common aliases (e.g., `AdminCenter`), warns for services that must be connected manually (AdminCenter, ConditionalAccess, SharePoint, Teams, Compliance), and will not fail the runner on unsupported splatted parameters.


### Changed
- Start-CISM365Audit
  - Aggregates `Services` from control descriptors, deduplicates, and calls Connect-CISM365Services with a safe splat.
  - Normalizes control Audit outputs into a stable results shape (Status, Findings, Remediation, RawResult) so reporting and summary counts are reliable.
- Connect-CISM365Services
  - Removed strict ValidateSet on service parameter; added tolerant mapping and splat-parameter acceptance to avoid "parameter not found" parse/bind errors.
  - Honors `ErrorOnFailure`: when set the helper will throw errors for connection failures; otherwise it warns and continues.
  - Accepts Tenant/TenantId/TenantDomain/Credential/ErrorOnFailure to match how Start-CISM365Audit splats connection parameters.

### Fixed
- Fixes to several control files (removed duplicate `function` keywords, normalized control descriptors) so they conform to the runner's expected descriptor shape.
- Parser and interpolation issues inside Connect-CISM365Services were corrected (safe error formatting and handling).

### Notes
- The runner remains conservative: only Graph and ExchangeOnline are auto-connected (best-effort, interactive) — other admin surfaces are intentionally left manual to avoid brittle automation.
- If you want non-interactive Graph sign-in (service principal / certificate / app-only auth), we can add support to pass those credentials through the runner and use `Connect-MgGraph -ClientId -TenantId -CertificateThumbprint` or similar.


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
