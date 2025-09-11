# Control: 5.1.2.6 (L2) Ensure 'LinkedIn account connections' is disabled
function Get-CISM365Control_5_1_2_6 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '5.1.2.6'
        Name        = "Ensure 'LinkedIn account connections' is disabled"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AzureAD', 'Entra')
        Description = @'
LinkedIn account connections allow users to connect their Microsoft work or school account with LinkedIn. Disabling this integration prevents potential security risks and accidental information disclosure.
'@
        Rationale   = @'
Disabling LinkedIn integration helps prevent phishing attacks and scenarios where external parties could access or disclose sensitive organizational information.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/linkedinintegration',
            'https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/linkedinuser-consent'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Navigate to Microsoft Entra admin center (https://entra.microsoft.com/).",
                    "2. Go to Identity > Users > User settings.",
                    "3. Under LinkedIn account connections, ensure 'No' is selected.",
                    "",
                    "Remediation:",
                    "1. In the same area, set LinkedIn account connections to 'No' and click Save."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify LinkedIn account connections are disabled for all users.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}