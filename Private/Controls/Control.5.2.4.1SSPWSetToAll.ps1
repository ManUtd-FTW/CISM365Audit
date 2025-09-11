function Get-CISM365Control_5_2_4_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id = '5.2.4.1'
        Name = 'Ensure Self Service Password Reset is set to "All"'
        Profile = 'L1'
        Automated = $true
        Services = @('AzureAD')
        Description = @'
Ensure that Azure AD Self-Service Password Reset (SSPR) is enabled for all users to allow secure password recovery without administrator intervention.
'@
        Rationale = @'
Enabling SSPR for all users improves security and reduces helpdesk workload by allowing users to reset their passwords securely and independently. Microsoft recommends enabling SSPR for all users.
'@
        References = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-sspr-howitworks',
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/howto-sspr-deployment'
        )
        Audit = {
            try {
                $ssprConfig = Get-AzureADMSPasswordResetPolicy

                if (-not $ssprConfig) {
                    "FAIL (Unable to retrieve SSPR policy)"
                    return
                }

                $scope = $ssprConfig.SelfServicePasswordResetPolicyScope

                if ($scope -eq "All") {
                    "PASS (Self-Service Password Reset is enabled for all users)"
                } else {
                    "FAIL (SSPR is not enabled for all users. Current scope: $scope)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}
