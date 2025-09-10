<#
Control: 1.3.5 Ensure internal phishing protection for Forms is enabled (L1)

This control is MANUAL by design (the setting is managed in the Microsoft 365 admin center UI).
The function is defensive and returns a normalized PSCustomObject that your runner can consume directly.

Usage:
  . .\Controls\Control-1.3.5.ps1
  $r = Get-Control_1_3_5 -Tenant 'contoso.onmicrosoft.com'
  $r | Format-List -Force
#>

function Get-Control_1_3_5 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Tenant = 'contoso.onmicrosoft.com',

        # Optional: an authenticated session object if you later want to attempt an automated check
        [Parameter(Mandatory=$false)]
        $Session = $null
    )

    $id = '1.3.5'
    $title = "Ensure internal phishing protection for Forms is enabled"
    $description = @'
Microsoft Forms can be used for phishing attacks by requesting personal or sensitive information.
Enable internal phishing protection for Forms to proactively detect and block suspicious forms.
'@.Trim()
    $profile = 'L1'
    $automated = $false
    $defaultValue = 'Enabled'

    $auditSteps = @(
        "1. Sign in to Microsoft 365 admin center: https://admin.microsoft.com",
        "2. In the left nav expand Settings then select Org settings",
        "3. Under Services select 'Microsoft Forms'",
        "4. Under 'Phishing protection' ensure the checkbox labeled 'Add internal phishing protection' is checked"
    )

    $remediation = @(
        "1. Sign in to Microsoft 365 admin center: https://admin.microsoft.com",
        "2. In the left nav expand Settings then select 'Org settings'",
        "3. Under Services select 'Microsoft Forms'",
        "4. Check the box labeled 'Add internal phishing protection' under 'Phishing protection' and click Save"
    )

    $references = @(
        'https://learn.microsoft.com/en-US/microsoft-forms/administrator-settingsmicrosoft-forms',
        'https://learn.microsoft.com/en-US/microsoft-forms/review-unblock-forms-usersdetected-blocked-potential-phishing'
    )

    try {
        # Manual control: return guidance for auditors/operators.
        $finding = "MANUAL: Verify in Microsoft 365 admin center that 'Add internal phishing protection' is checked under Microsoft Forms → Phishing protection."
        return [PSCustomObject]@{
            Id = $id
            Title = $title
            Description = $description
            Status = 'MANUAL'       # PASS | FAIL | MANUAL | ERROR
            Finding = $finding
            Profile = $profile
            Automated = $automated
            Tenant = $Tenant
            DefaultValue = $defaultValue
            References = $references
            AuditSteps = $auditSteps
            Remediation = $remediation
            RawResult = $null
        }
    }
    catch {
        return [PSCustomObject]@{
            Id = $id
            Title = $title
            Description = $description
            Status = 'ERROR'
            Finding = "ERROR: $($_.Exception.Message)"
            Profile = $profile
            Automated = $automated
            Tenant = $Tenant
            DefaultValue = $defaultValue
            References = $references
            AuditSteps = $auditSteps
            Remediation = $remediation
            RawResult = $null
        }
    }
}