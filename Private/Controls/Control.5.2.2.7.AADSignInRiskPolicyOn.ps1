function Get-CISM365Control_5_2_2_7 {
    [OutputType([hashtable])]
    param()

    @{
        Id = '5.2.2.7'
        Name = 'Ensure Azure AD Identity Protection sign-in risk policy is enabled'
        Profile = 'L1'
        Automated = $true
        Services = @('Graph')
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
                # Ensure the module is available
                if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Identity.SignIns)) {
                    Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force
                }

                # Connect to Graph if not already connected
                if (-not (Get-MgContext)) {
                    Connect-MgGraph -Scopes "Policy.Read.All"
                }

                # Retrieve all Conditional Access policies
                $policies = Get-MgIdentityConditionalAccessPolicy -All

                # Filter for sign-in risk policies (Graph property names)
                $signInRiskPolicies = $policies | Where-Object {
                    $_.Conditions.Users.IncludeUsers -contains "All" -and
                    $_.Conditions.SignInRiskLevels -ne $null
                }

                if (-not $signInRiskPolicies) {
                    "FAIL (No sign-in risk policy found)"
                    return
                }

                $enabledPolicy = $signInRiskPolicies | Where-Object { $_.State -eq "enabled" } | Select-Object -First 1

                if ($enabledPolicy) {
                    "PASS (Sign-in risk policy is enabled: $($enabledPolicy.DisplayName))"
                }
                else {
                    $disabled = $signInRiskPolicies | Select-Object -First 1
                    "FAIL (Sign-in risk policy exists but is not enabled: $($disabled.DisplayName))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}