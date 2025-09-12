function Get-CISM365Control_5_2_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.2.3.1'
        Name        = "Ensure Azure AD Password Protection is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Azure AD Password Protection helps prevent use of weak and banned passwords."
        Rationale   = "Reduces risk of password-based attacks and credential compromise."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-password-ban-bad'
        )
        Audit       = {
            try {
                $settings = Get-MgPolicyAuthenticationStrengthPolicy
                $enabled = $settings | Where-Object { $_.IsEnabled -eq $true }
                if ($enabled.Count -gt 0) {
                    "PASS (Azure AD Password Protection is enabled)"
                } else {
                    "FAIL (Azure AD Password Protection is NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check Azure AD Password Protection status: $($_.Exception.Message))"
            }
        }
    }
}