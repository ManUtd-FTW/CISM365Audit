function Get-CISM365Control_5_4_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.4.1'
        Name        = "Ensure MFA registration campaign is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Azure AD MFA registration campaign should be enabled to prompt all users to register MFA."
        Rationale   = "Mandatory MFA enrollment ensures strong authentication for all users."
        References  = @(
            'https://learn.microsoft.com/en-us/entra/identity/authentication-methods-policy-registration-campaign'
        )
        Audit       = {
            try {
                $policy = Get-MgPolicyAuthenticationMethodsPolicy
                if ($policy.RegistrationCampaign.Enabled -eq $true) {
                    "PASS (MFA registration campaign is enabled)"
                } else {
                    "FAIL (MFA registration campaign is NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check MFA registration campaign status: $($_.Exception.Message))"
            }
        }
    }
}