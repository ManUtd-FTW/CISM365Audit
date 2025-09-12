function Get-CISM365Control_5_2_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.2.1.1'
        Name        = "Ensure User Risk Policy is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Azure AD Identity Protection User Risk Policy must be enabled to respond to detected risky users."
        Rationale   = "Automated response to risky sign-ins reduces risk of compromise."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/howto-identity-protection-configure-user-risk-policy'
        )
        Audit       = {
            try {
                $riskPolicies = Get-MgIdentityProtectionPolicyUserRiskPolicy
                $enabled = $riskPolicies | Where-Object { $_.IsEnabled -eq $true }
                if ($enabled.Count -gt 0) {
                    "PASS (User Risk Policy is enabled)"
                } else {
                    "FAIL (User Risk Policy is NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check User Risk Policy status: $($_.Exception.Message))"
            }
        }
    }
}