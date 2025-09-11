function Get-CISM365Control_5_1_2_7 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.2.7'
        Name        = 'Ensure Multi-Factor Authentication (MFA) is enabled for all users'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('AzureAD','Graph')
        Description = @'
Require MFA for all users to prevent credential-based attacks and protect access to Microsoft 365 resources.
'@
        Rationale   = @'
MFA reduces the risk of unauthorized access due to compromised credentials. Enforcing MFA is a critical Microsoft security best practice.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks',
            'https://learn.microsoft.com/en-us/entra/identity/conditional-access/how-to-policy-mfa'
        )
        Audit = {
            try {
                # Connect-MgGraph must already be run by orchestrator

                # Get all enabled users (excluding guests)
                $users = Get-MgUser -All | Where-Object { $_.UserType -eq 'Member' -and $_.AccountEnabled -eq $true }
                $mfaStates = @()
                foreach ($user in $users) {
                    # MFA status can be checked via authentication methods
                    $methods = Get-MgUserAuthenticationMethod -UserId $user.Id
                    $hasMfa = $false
                    foreach ($method in $methods) {
                        # Look for MFA methods (Authenticator, FIDO2, Phone, Software OATH, etc.)
                        if ($method.AdditionalProperties['@odata.type'] -in @(
                            '#microsoft.graph.microsoftAuthenticatorAuthenticationMethod',
                            '#microsoft.graph.phoneAuthenticationMethod',
                            '#microsoft.graph.fido2AuthenticationMethod',
                            '#microsoft.graph.softwareOathAuthenticationMethod'
                        )) {
                            $hasMfa = $true
                            break
                        }
                    }
                    $mfaStates += [PSCustomObject]@{ User = $user.UserPrincipalName; HasMFA = $hasMfa }
                }
                $nonCompliant = $mfaStates | Where-Object { $_.HasMFA -eq $false }
                if ($nonCompliant.Count -eq 0) {
                    "PASS (All enabled users have at least one MFA method registered)"
                } else {
                    "FAIL (These users do NOT have MFA enabled: $($nonCompliant.User -join ', '))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}