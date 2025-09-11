# Control: 5.1.2.2 (L2) Ensure third party integrated applications are not allowed
function Get-CISM365Control_5_1_2_2 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '5.1.2.2'
        Name        = "Ensure third party integrated applications are not allowed"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AzureAD', 'Entra')
        Description = @'
App registrations allow users to register custom-developed applications for use within the directory. This setting should be disabled to prevent unauthorized third-party integrations.
'@
        Rationale   = @'
Disabling third party integrated applications prevents attackers from using breached accounts to grant access to malicious applications and exfiltrate data. Only enable if there is a clear business need and strong security controls.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/develop/active-directoryhow-applications-are-added'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Navigate to Microsoft Entra admin center (https://entra.microsoft.com/).",
                    "2. Go to Identity > Users > Users settings.",
                    "3. Verify 'Users can register applications' is set to 'No'.",
                    "",
                    "Remediation:",
                    "1. In the same area, set 'Users can register applications' to 'No' and click Save."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify Third Party integrated apps are not allowed.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}