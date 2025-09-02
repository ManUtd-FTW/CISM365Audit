
# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2025-09-02
### Added
- Initial module structure with `CISM365Audit.psd1`, `CISM365Audit.psm1`, and organized `Public` and `Private` folders.
- `Start-CISM365Audit` function to run CIS Microsoft 365 audit.
- `Connect-CISM365Services` function to handle Microsoft Graph and Exchange Online authentication.
- Implemented three CIS controls from v3.0.0:
  - 1.1.3: Global Admins count via Microsoft Graph.
  - 2.1.9: DKIM enabled for all custom domains.
  - 2.1.1: Safe Links enabled for Office applications.
- Minimal HTML report generation with PASS/FAIL/MANUAL/ERROR status.
