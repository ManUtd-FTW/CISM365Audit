function Get-CISM365Control_5_2_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.2.2.1'
        Name        = "Ensure Sign-in Risk Policy is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Azure AD Identity Protection Sign-In Risk Policy must be enabled to respond to risky sign-ins."
        Rationale   = "Mitigates risks associated with suspicious or anomalous sign-in attempts."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/howto-identity-protection-configure-sign-in-risk-policy'
        )
        Audit       = {
            try {
                $riskPolicies = Get-MgIdentityProtectionPolicySignInRiskPolicy
                $enabled = $riskPolicies | Where-Object { $_.IsEnabled -eq $true }
                if ($enabled.Count -gt 0) {
                    "PASS (Sign-in Risk Policy is enabled)"
                } else {
                    "FAIL (Sign-in Risk Policy is NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check Sign-in Risk Policy status: $($_.Exception.Message))"
            }
        }
    }
}