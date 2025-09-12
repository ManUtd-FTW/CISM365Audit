function Get-CISM365Control_5_3_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.3.2'
        Name        = "Ensure risky users are automatically remediated"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Azure AD should automatically block or require password reset for high-risk users using Identity Protection."
        Rationale   = "Automated remediation of risky users prevents account compromise."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/howto-identity-protection-configure-user-risk-policy'
        )
        Audit       = {
            try {
                $policy = Get-MgIdentityProtectionPolicyUserRiskPolicy
                if ($policy.IsEnabled -eq $true -and ($policy.Actions -contains 'block' -or $policy.Actions -contains 'resetPassword')) {
                    "PASS (Risky users are automatically remediated)"
                } else {
                    "FAIL (Automatic remediation for risky users is NOT enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check risky user remediation settings: $($_.Exception.Message))"
            }
        }
    }
}