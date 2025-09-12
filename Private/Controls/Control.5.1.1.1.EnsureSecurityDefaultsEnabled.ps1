function Get-CISM365Control_5_1_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.1.1'
        Name        = "Ensure Azure AD Security Defaults are enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Azure AD Security Defaults provide baseline protections (MFA, blocking legacy auth, etc.)."
        Rationale   = "Enables essential identity protection with minimal configuration."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/concept-fundamentals-security-defaults'
        )
        Audit       = {
            try {
                $defaults = Get-MgPolicyAuthenticationMethodsPolicy
                if ($defaults.IsEnabled) {
                    "PASS (Security Defaults are enabled)"
                } else {
                    "FAIL (Security Defaults are NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check Security Defaults status: $($_.Exception.Message))"
            }
        }
    }
}