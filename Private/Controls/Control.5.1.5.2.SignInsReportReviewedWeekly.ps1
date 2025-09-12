# Control: 5.1.5.2 (L2) Ensure the Sign-ins report is reviewed at least weekly
function Get-CISM365Control_5_1_5_2 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '5.1.5.2'
        Name        = "Ensure the Sign-ins report is reviewed at least weekly"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AzureAD', 'Entra')
        Description = @'
The Sign-ins report provides visibility into user and app sign-in activity in Azure AD. Reviewing this report regularly helps detect suspicious activity, unauthorized access, and potential brute-force attacks.
'@
        Rationale   = @'
Regular review of sign-in activity helps organizations promptly identify and respond to security incidents, reducing the risk of account compromise or data loss.
'@
        References  = @()
        Audit = {
            try {
                $steps = @(
                    "1. Confirm that documented procedures exist to review the Sign-ins report at least weekly.",
                    "2. Verify those procedures are being followed by appropriate personnel.",
                    "3. (Optional) Review logs or other documentation showing recent reviews.",
                    "",
                    "Remediation:",
                    "1. Navigate to Microsoft Entra admin center (https://entra.microsoft.com/).",
                    "2. Go to Identity > Monitoring & health > Sign-in logs.",
                    "3. Review the Sign-ins report."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify the Sign-ins report is reviewed at least weekly by appropriate personnel.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}Control: 5.1.5.2 (L2) Ensure the Sign-ins report is reviewed at least weekly
function Get-CISM365Control_5_1_5_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.5.2'
        Name        = "Ensure the Sign-ins report is reviewed at least weekly"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AzureAD', 'Entra')
        Description = "The Sign-ins report provides visibility into user and app sign-in activity in Azure AD. Reviewing this report regularly helps detect suspicious activity, unauthorized access, and potential brute-force attacks."
        Rationale   = "Regular review of sign-in activity helps organizations promptly identify and respond to security incidents, reducing the risk of account compromise or data loss."
        References  = @()
        Audit       = {
            @"
MANUAL:
1. Confirm that documented procedures exist to review the Sign-ins report at least weekly.
2. Verify those procedures are being followed by appropriate personnel.
3. (Optional) Review logs or other documentation showing recent reviews.

Remediation:
1. Navigate to Microsoft Entra admin center (https://entra.microsoft.com/).
2. Go to Identity > Monitoring & health > Sign-in logs.
3. Review the Sign-ins report.
"@
        }
    }
}