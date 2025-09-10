# CISM365Audit

Minimal PowerShell module to audit a Microsoft 365 tenant against a subset of the **CIS Microsoft 365 Foundations Benchmark (v5.0.0.3)** and produce a simple HTML report.

> **Status:** v0.0.7 (latest)

---

## ✨ Features
- Lightweight PowerShell module structure (`.psd1`, `.psm1`, `Public/`, `Private/`).
- Single entrypoint: `Start-CISM365Audit`.
- Self-contained connection checks (Microsoft Graph + Exchange Online).
- **Updated report layout** for improved readability and summary.
- Minimal HTML report with PASS / FAIL / MANUAL / ERROR states.

## ✅ Controls Implemented (v0.0.7)
- Existing controls:
  - **1.1.3** – Ensure that between two and four Global Admins are designated (via Microsoft Graph; counts users including group membership).
  - **2.1.9** – Ensure that DKIM is enabled for all Exchange Online domains (custom authoritative domains only).
  - **2.1.1** – Ensure Safe Links for Office applications is enabled (reads `Get-AtpPolicyForO365`).
- **New controls added in v0.0.7:**
    - **2.2.x** – 
    - **3.1.x** – 

---

## 📦 Requirements
- **PowerShell**: Windows PowerShell 5.1 or PowerShell 7+
- **Modules** (install if missing):
  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser
  Install-Module ExchangeOnlineManagement -Scope CurrentUser
  ```
- **Permissions**:
  - Microsoft Graph: `Directory.Read.All` (delegated) when prompted.
  - Exchange Online: Ability to connect and read org settings (e.g., Security Reader/Global Reader or EXO role with equivalent rights).

> Tip: The module will attempt to connect interactively if required permissions/sessions are not already present.

---

## 🔧 Install (Local)
Clone or download the repo, then import the module from the project root:

```powershell
# From the repo root
Import-Module .\CISM365Audit.psd1 -Force
# or
Import-Module .\CISM365Audit.psm1 -Force
```

> You can also copy the entire folder into one of your `$env:PSModulePath` locations to import by name.

---

## 🚀 Quick Start
Run an audit for your tenant (use your tenant's initial domain like `contoso.onmicrosoft.com` or your vanity domain where applicable):

```powershell
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com"
```

This generates `CISM365AuditReport.html` in the working directory.

---

## 📚 Usage Examples
### 1) Basic audit with default output
```powershell
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com"
```

### 2) Custom output path
```powershell
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com" -OutputPath ".\Reports\report.html"
```

### 3) Verbose logging (helpful for connection and control flow)
```powershell
$VerbosePreference = 'Continue'
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com"
$VerbosePreference = 'SilentlyContinue'
```

### 4) (Optional) Pre-connect to services
If your module version exports `Connect-CISM365Services`, you can connect up-front and then run the audit:
```powershell
# Connect to Microsoft Graph & Exchange Online (interactive)
Connect-CISM365Services -Scopes 'Directory.Read.All' -Organization "contoso.onmicrosoft.com"

# Run the audit
Start-CISM365Audit -Tenant "contoso.onmicrosoft.com" -OutputPath .\CISM365AuditReport.html
```
> If `Connect-CISM365Services` is not exported in your build, `Start-CISM365Audit` will still attempt to connect as needed.

---

## 🧾 Output
- **HTML report** (default: `CISM365AuditReport.html`) with a summary and a table of controls:
  - **PASS** – The control meets the benchmark requirement.
  - **FAIL** – The control does not meet the requirement.
  - **MANUAL** – Requires manual review or information not available via API/cmdlet.
  - **ERROR** – An exception occurred while evaluating the control.
- **New in v0.0.7:** Updated layout for clearer summaries, improved styling, and enhanced readability.

---

## 🛠️ Troubleshooting
- **Missing modules**: Install required modules (see Requirements) and re-import the module.
- **Graph consent**: First-time Graph sign-in may require admin consent for `Directory.Read.All`.
- **EXO connection**: If `Get-ConnectionInformation` shows not connected, run `Connect-ExchangeOnline -Organization <tenant>` and retry.
- **Permissions**: Use an account with at least **Global Reader/Security Reader** for tenant-wide reads.

---

## 🧭 Roadmap (Next)
- Further improvements to HTML styling (summary badges, consistent colors, better layout).
- Expand control coverage (additional CIS v3.0.0 items, then v5 mapping).
- Optional: Export `Connect-CISM365Services` and add `Disconnect-CISM365Services`.
- Optional: App-only authentication for CI/CD.

---

## 🔖 Versioning & Changelog
- Version tags follow `v<major>.<minor>.<patch>`.
- See [CHANGELOG.md](CHANGELOG.md) for details.

---

## 🤝 Contributing
Issues and PRs are welcome. Keep changes minimal and focused; prefer incremental versions (e.g., `0.0.2`, `0.0.3`).

---

## ⚠️ Disclaimer
This project is not affiliated with or endorsed by the Center for Internet Security (CIS). Control mappings are provided for convenience and may require validation against the official benchmark for your environment.