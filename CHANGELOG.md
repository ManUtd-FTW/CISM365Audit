# Changelog

All notable changes to this project are documented in this file.

## [0.0.6] - 2025-09-08
### Added
- Centralized Connect-CISM365Services helper that accepts a flexible set of service identifiers and common splatted parameters (Tenant, TenantId, TenantDomain, Credential, ErrorOnFailure). This prevents parameter-binding errors when the runner splats connection parameters.
- Start-CISM365Audit now aggregates required services from discovered controls and calls Connect-CISM365Services before executing controls.
- Lean automatic interactive sign-in behavior:
  - When controls request `Services = @('Graph')`, Connect-CISM365Services will attempt `Connect-MgGraph` if Microsoft.Graph cmdlets are available and no active context exists.
  - When controls request `Services = @('ExchangeOnline')`, Connect-CISM365Services will attempt `Connect-ExchangeOnline` if the ExchangeOnlineManagement module is available and no active session exists.
- Controls updated to be session-preserving:
  - Controls that rely on Microsoft Graph (example: Control.1.1.1.CloudOnlyAdmins) now check for the Microsoft Graph PowerShell SDK and an active context (`Get-MgContext`) and return a `MANUAL` result with clear remediation if no session exists, rather than attempting sign-in themselves.

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

## [0.0.1] - baseline
- Initial baseline release and sample controls implemented.
