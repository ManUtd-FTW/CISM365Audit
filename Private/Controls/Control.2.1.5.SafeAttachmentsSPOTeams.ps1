function Get-CISM365Control_2_1_5 {
    [OutputType([hashtable])]
    param()

    return @{
        Id        = '2.1.5'
        Name      = 'Ensure Safe Attachments for SharePoint, OneDrive, and Microsoft Teams is enabled'
        Profile   = 'L2'
        Automated = $true
        Services  = @('ExchangeOnline')   # Uses Exchange/Protection cmdlets exposed when connected to Exchange Online
        Description = @'
Safe Attachments for SharePoint, OneDrive, and Microsoft Teams scans these services for malicious files and prevents users from opening,
copying, moving, or sharing files that are identified as malicious.
'@
        Rationale = 'Protects collaboration surfaces (SharePoint/OneDrive/Teams) from malware and reduces risk of spread via shared files.'
        References = @(
            'https://learn.microsoft.com/defender-office-365/safe-attachments-about',
            'https://learn.microsoft.com/defender-office-365/safe-attachments-policies-configure'
        )
        Audit = {
            try {
                # Required cmdlet for programmatic audit
                if (-not (Get-Command -Name Get-AtpPolicyForO365 -ErrorAction SilentlyContinue)) {
                    return "MANUAL (Get-AtpPolicyForO365 cmdlet is not available in this session. Install the module that provides it and/or pre-authenticate (Connect-ExchangeOnline) and re-run.)"
                }

                # Retrieve tenant-wide ATP/O365 settings
                $policy = Get-AtpPolicyForO365 -ErrorAction Stop

                if (-not $policy) {
                    return "MANUAL (No ATP/O365 policy object returned by Get-AtpPolicyForO365; verify connectivity to Exchange Online / Defender portal.)"
                }

                # Ensure expected properties exist on the returned object
                $expectedProps = @('EnableATPForSPOTeamsODB','EnableSafeDocs','AllowSafeDocsOpen')
                $missing = @()
                foreach ($p in $expectedProps) {
                    if (-not ($policy.PSObject.Properties.Name -contains $p)) { $missing += $p }
                }
                if ($missing.Count -gt 0) {
                    return "MANUAL (Returned policy is missing expected properties: $($missing -join ', '). Verify in the Defender portal.)"
                }

                # Normalize values
                $enableSPOTeams = [bool]$policy.EnableATPForSPOTeamsODB
                $enableSafeDocs  = [bool]$policy.EnableSafeDocs
                $allowSafeOpen   = [bool]$policy.AllowSafeDocsOpen

                # Expected secure configuration
                $ok = $true
                $issues = @()
                if (-not $enableSPOTeams) { $ok = $false; $issues += "EnableATPForSPOTeamsODB = $enableSPOTeams (expected True)" }
                if (-not $enableSafeDocs)  { $ok = $false; $issues += "EnableSafeDocs = $enableSafeDocs (expected True)" }
                if ($allowSafeOpen)        { $ok = $false; $issues += "AllowSafeDocsOpen = $allowSafeOpen (expected False)" }

                if ($ok) {
                    return "PASS (EnableATPForSPOTeamsODB=True; EnableSafeDocs=True; AllowSafeDocsOpen=False)"
                }

                # Build helpful audit + remediation text
                $auditSteps = @(
                    "1. Connect to Exchange Online: Connect-ExchangeOnline",
                    "2. Run: Get-AtpPolicyForO365 | fl Name,EnableATPForSPOTeamsODB,EnableSafeDocs,AllowSafeDocsOpen",
                    "3. Verify the values: EnableATPForSPOTeamsODB = True, EnableSafeDocs = True, AllowSafeDocsOpen = False"
                )

                $remediationSteps = @(
                    "1. Connect to Exchange Online: Connect-ExchangeOnline",
                    "2. Run: Set-AtpPolicyForO365 -EnableATPForSPOTeamsODB $true -EnableSafeDocs $true -AllowSafeDocsOpen $false",
                    "3. Alternatively, in the Microsoft 365 Defender portal (https://security.microsoft.com):",
                    "   - Under Email & collaboration → Policies & rules → Threat policies → Safe Attachments → Global settings",
                    "   - Enable 'Turn on Defender for Office 365 for SharePoint, OneDrive, and Microsoft Teams'",
                    "   - Enable 'Turn on Safe Documents for Office clients'",
                    "   - Disable 'Allow people to click through Protected View even if Safe Documents identified the file as malicious'",
                    "   - Save changes"
                )

                $issueText = $issues -join '; '
                $auditText = $auditSteps -join "`n"
                $remediationText = $remediationSteps -join "`n"

                $message = @"
FAIL ($issueText)

Audit steps:
$auditText

Remediation steps:
$remediationText
"@

                return $message
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}