function Get-CISM365Control_8_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.2.1'
        Name        = "Ensure 'external access' is restricted in the Teams admin center"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Restricts chat with unmanaged Skype and Teams users. Only approved domains should be allowed.
'@
        Rationale   = @'
Restricting external access minimizes risk of data loss, phishing, and social engineering attacks.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/skypeforbusiness/set-up-skype-for-business-online/set-up-skype-for-business-online',
            'https://learn.microsoft.com/en-US/microsoftteams/manage-external-access?WT.mc_id=TeamsAdminCenterCSH'
        )
        Audit = {
            try {
                $config = Get-CsTenantFederationConfiguration
                $allBlocked = ($config.AllowTeamsConsumer -eq $false) -and
                              ($config.AllowPublicUsers -eq $false) -and
                              ($config.AllowFederatedUsers -eq $false)
                if ($allBlocked) {
                    "PASS (All external access is blocked)"
                } else {
                    "FAIL (External access is permitted: TeamsConsumer=$($config.AllowTeamsConsumer), PublicUsers=$($config.AllowPublicUsers), FederatedUsers=$($config.AllowFederatedUsers))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}