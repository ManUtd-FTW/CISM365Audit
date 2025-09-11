function Get-CISM365Control_5_2_2_6 {
    [OutputType([hashtable])]
    param()

    @{
        Id = '5.2.2.6'
        Name = 'Ensure Azure AD Identity Protection user risk policy is enabled'
        Profile = 'L1'
        Automated = $true
        Services = @('AzureAD')
        Description = @'
Ensure that the Azure AD Identity Protection user risk policy is enabled to automatically respond to risky sign-ins and compromised accounts.
'@
        Rationale = @'
User risk policies help detect and respond to compromised identities by enforcing actions such as requiring password changes or blocking access. Enabling this policy is a Microsoft security best practice.
'@
        References = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/howto-identity-protection-policies',
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/user-risk-policy'
        )
        Audit = {
            try {
                $policy = Get-AzureADMSConditionalAccessPolicy | Where-Object {
                    $_.Conditions.Users.Include -contains "All" -and
                    $_.Conditions.SignInRiskLevels -eq $null -and
                    $_.Conditions.UserRiskLevels -ne $null
                }

                if (-not $policy) {
                    "FAIL (No user risk policy found)"
                    return
                }

                $enabled = $policy.State -eq "enabled"

                if ($enabled) {
                    "PASS (User risk policy is enabled: $($policy.DisplayName))"
                } else {
                    "FAIL (User risk policy exists but is not enabled: $($policy.DisplayName))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}
