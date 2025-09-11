function Get-CISM365Control_5_2_2_7{
    [OutputType([hashtable])]
    param()

    @{
        Id = '5.2.2.7'
        Name = 'Ensure Azure AD Identity Protection sign-in risk policy is enabled'
        Profile = 'L1'
        Automated = $true
        Services = @('AzureAD')
        Description = @'
Ensure that the Azure AD Identity Protection sign-in risk policy is enabled to automatically respond to risky sign-ins and reduce the risk of account compromise.
'@
        Rationale = @'
Sign-in risk policies help detect and respond to suspicious sign-in behavior by enforcing actions such as requiring MFA or blocking access. Enabling this policy is a Microsoft security best practice.
'@
        References = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/howto-identity-protection-policies',
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/sign-in-risk-policy'
        )
        Audit = {
            try {
                $policy = Get-AzureADMSConditionalAccessPolicy | Where-Object {
                    $_.Conditions.Users.Include -contains "All" -and
                    $_.Conditions.SignInRiskLevels -ne $null
                }

                if (-not $policy) {
                    "FAIL (No sign-in risk policy found)"
                    return
                }

                $enabled = $policy.State -eq "enabled"

                if ($enabled) {
                    "PASS (Sign-in risk policy is enabled: $($policy.DisplayName))"
                } else {
                    "FAIL (Sign-in risk policy exists but is not enabled: $($policy.DisplayName))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}
