# Control: 5.1.5.3 (L2) Ensure group owner consent to apps accessing company data for groups is not allowed
function Get-CISM365Control_5_1_5_3 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '5.1.5.3'
        Name        = "Ensure group owner consent to apps accessing company data for groups is not allowed"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AzureAD', 'Entra')
        Description = @'
Control when group owners are allowed to grant consent to applications accessing company data for groups. Disabling group owner consent mitigates the risk of malicious apps gaining access to sensitive group data.
'@
        Rationale   = @'
Attackers may target group owners to trick them into granting access to group data. Disabling group owner consent reduces the threat surface by ensuring only administrators can grant such access.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?pivots=portal'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Navigate to Microsoft Entra admin center (https://entra.microsoft.com/).",
                    "2. Go to Identity > Applications > Enterprise applications.",
                    "3. Under Security, select Consent and permissions > Group owner consent settings.",
                    "4. Verify 'Group owner consent for applications' is set to 'Do not allow group owner consent'.",
                    "",
                    "Remediation:",
                    "1. In the same area, set 'Group owner consent for applications' to 'Do not allow group owner consent' and click Save."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify group owner consent to apps accessing company data for groups is not allowed.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}