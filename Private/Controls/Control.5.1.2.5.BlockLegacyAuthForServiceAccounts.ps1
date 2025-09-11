function Get-CISM365Control_5_1_2_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.2.5'
        Name        = 'Ensure legacy authentication is blocked for service accounts'
        Profile     = 'L2'
        Automated   = $true
        Services    = @('AzureAD','ExchangeOnline')
        Description = @'
Block legacy authentication for all service accounts to reduce attack surface and prevent credential-based attacks.
'@
        Rationale   = @'
Service accounts are high value targets for attackers and should not use insecure legacy authentication protocols.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/entra/identity/conditional-access/block-legacy-authentication',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/disable-basic-authentication?view=o365-worldwide'
        )
        Audit = {
            try {
                # Service accounts are typically identified by naming convention or group membership
                $serviceAccounts = Get-MgUser -All | Where-Object {
                    $_.UserType -eq 'Member' -and
                    ($_.DisplayName -match 'svc|service|automation|bot' -or $_.JobTitle -match 'Service Account')
                }
                $failList = @()
                foreach ($acct in $serviceAccounts) {
                    $mailbox = Get-Mailbox -Identity $acct.UserPrincipalName -ErrorAction SilentlyContinue
                    if ($mailbox) {
                        $authPolicies = $mailbox.AuthenticationPolicy
                        if (-not $authPolicies -or $authPolicies -eq "") {
                            $failList += $acct.UserPrincipalName
                        }
                    }
                }
                if ($failList.Count -eq 0) {
                    "PASS (Legacy authentication blocked for all service accounts)"
                } else {
                    "FAIL (Legacy authentication NOT blocked for: $($failList -join ', '))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}