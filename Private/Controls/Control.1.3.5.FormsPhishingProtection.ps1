# Control: 1.3.5 Ensure internal phishing protection for Forms is enabled (L1)
function Get-CISM365Control_1_3_5 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.5'
        Name        = 'Ensure internal phishing protection for Forms is enabled'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('AdminCenter','Forms')
        Description = 'Enable internal phishing protection for Microsoft Forms to detect and block suspicious forms.'
        Rationale   = 'Protects against attackers using forms to harvest personal/sensitive information or distribute malicious URLs.'
        References  = @(
            'https://learn.microsoft.com/en-US/microsoft-forms/administrator-settings-microsoft-forms',
            'https://learn.microsoft.com/en-US/microsoft-forms/review-unblock-forms-users-detected-blocked-potential-phishing'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Sign in to Microsoft 365 admin center: https://admin.microsoft.com",
                    "2. In the left nav expand Settings then select 'Org settings'",
                    "3. Under Services select 'Microsoft Forms'",
                    "4. Under 'Phishing protection' ensure 'Add internal phishing protection' is checked"
                )

                $joined = $steps -join "`n"
                return "MANUAL: Verify via admin center that 'Add internal phishing protection' is checked.`nAudit steps:`n$joined`nDefault: Enabled"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}