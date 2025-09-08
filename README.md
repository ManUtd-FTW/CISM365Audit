
CISM365Audit — Minimal Microsoft 365 benchmark auditor (v0.0.6)

# CISM365Audit

Minimal PowerShell module to audit a Microsoft 365 tenant against a subset of the **CIS Microsoft 365 Foundations Benchmark (v5.0.0.3)** and produce a simple HTML report.

> **Status:** v0.0.6

---

## ✨ Summary of v0.0.6
This release centralizes connection handling and makes the runner more robust:

- Start-CISM365Audit now aggregates required services from discovered controls and calls a single connection helper (Connect-CISM365Services) before running checks.
- Connect-CISM365Services accepts a flexible set of service identifiers (e.g., 'Graph', 'AdminCenter') and common splatted parameters (Tenant, TenantId, TenantDomain, Credential, ErrorOnFailure), prevents parameter-binding errors, and attempts safe interactive sign-in only when appropriate.
- Controls have been made session-preserving: they detect an existing session and return a `MANUAL` result with remediation when no session exists, rather than trying to sign in themselves.

---

## ✨ Features
- Minimal PowerShell module structure (`.psd1`, `.psm1`, `Public/`, `Private/`).
- Single entrypoint: `Start-CISM365Audit`.
- Centralized connection helper: `Connect-CISM365Services` (auto-connects Graph/ExchangeOnline when possible).
- Minimal HTML report with PASS / FAIL / MANUAL / ERROR states.

---

## ✅ Controls Implemented (baseline examples)
- 1.1.3 – Ensure the number of Global Admins is appropriate.
- 2.1.9 – DKIM enabled for Exchange Online domains.
- 2.1.1 – Safe Links for Office applications.

(Controls may return MANUAL when a required session is not present.)

---

## 📦 Requirements
- PowerShell 7+ recommended (Windows PowerShell 5.1 may work, but modern modules assume PowerShell 7+).
- Optional modules (install if you want automated Graph/Exchange checks):
  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser
  Install-Module ExchangeOnlineManagement -Scope CurrentUser
  ```
- Appropriate permissions for the account you use to sign in (e.g., Directory.Read.All, Directory Roles read, Global Reader, or equivalent delegated rights).

---

## 🔧 Install (Local)
Clone or download the repo, then import the module from the project root:

```powershell
# From the repo root
Import-Module .\CISM365Audit.psd1 -Force
# or
Import-Module .\CISM365Audit.psm1 -Force
```

---

## 🚀 Quick Start
Run an audit for your tenant (use your tenant's initial domain like `contoso.onmicrosoft.com`):

```powershell
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com"
```

This generates `CISM365AuditReport.html` in the working directory.

---

## 🔌 Connect behavior (what changed)
- Start-CISM365Audit inspects all discovered controls and builds a deduped list of required services (the control descriptors expose `Services = @('Graph')`, etc.).
- If Graph is required and the Microsoft.Graph SDK is available but no Graph context exists, Connect-CISM365Services will attempt `Connect-MgGraph` interactively.
- If ExchangeOnline is required and the ExchangeOnlineManagement module is available but no session exists, it will attempt `Connect-ExchangeOnline` interactively.
- Other admin surfaces (AdminCenter, ConditionalAccess, SharePoint, Teams, Compliance) remain manual by default — Connect-CISM365Services will print verbose guidance rather than attempt brittle automation.

If you prefer to pre-authenticate manually (or to use non-interactive app-only auth), run the appropriate Connect-* cmdlets before invoking Start-CISM365Audit or use `-NoConnect` to skip the centralized connect attempt.

---

## 📚 Usage Examples
### Basic run (interactive sign-in if needed)
```powershell
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com" -Verbose
```

### Skip automatic connection (operator will sign in manually)
```powershell
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com" -NoConnect
```

### JSON + HTML output
```powershell
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com" -JsonOutputPath .\out\audit.json -OutputPath .\out\audit.html
```

---

## 🧾 Output
- HTML report (default: `CISM365AuditReport.html`) with summary and control table.
- JSON output if `-JsonOutputPath` is supplied.

---

## 🧭 Roadmap
- Improve HTML styling and layout.
- Broaden control coverage across the CIS benchmark.
- Optional: Add app-only authentication flows for CI/CD.
- Optional: Export Connect/Disconnect helpers for consumers.

---

## 🛠 Troubleshooting
- "Authentication needed. Please call Connect-MgGraph." — Either run Start-CISM365Audit without `-NoConnect` so it can prompt for Graph sign-in, or sign-in manually with `Connect-MgGraph` before running.
- Parameter-binding errors when splatting connection parameters — resolved in v0.0.6 by making Connect-CISM365Services accept common splatted keys (`Tenant`, `TenantId`, `TenantDomain`, `Credential`, `ErrorOnFailure`).
- Missing modules — install Microsoft.Graph or ExchangeOnlineManagement as needed.

---

## 🔖 Versioning & Changelog
- Version tags follow `v<major>.<minor>.<patch>`.
- See CHANGELOG.md for details for v0.0.6.

---

## 🤝 Contributing
Contributions, issues, and PRs are welcome. When adding new controls:
- Declare required services via the control descriptor's `Services` array (e.g., `Services = @('Graph')`) so the runner can attempt centralized sign-in.
- Prefer session-preserving controls: detect session presence and return MANUAL if absent.

---

## ⚠️ Disclaimer
This project is not affiliated with or endorsed by the Center for Internet Security (CIS). Control mappings are provided for convenience and may require validation against the official benchmark.
