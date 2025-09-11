function Get-CISM365Control_8_5_9 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.5.9'
        Name        = 'Restrict Teams app installation to approved apps only'
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Restrict installation of Teams apps to those approved by the organization using Teams app permission policies.
'@
        Rationale   = @'
Restricting app installation reduces risk from untrusted or malicious third-party apps.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoftteams/teams-app-permission-policies',
            'https://learn.microsoft.com/en-us/microsoftteams/teams-app-setup-policies'
        )
        Audit = {
            try {
                $policies = Get-CsTeamsAppPermissionPolicy
                $failList = @()
                foreach ($policy in $policies) {
                    if ($policy.AllowUserApps -eq $true -and ($policy.AllowedAppIds.Count -eq 0)) {
                        $failList += $policy.Identity
                    }
                }
                if ($failList.Count -eq 0) {
                    "PASS (Teams app installation is restricted to approved apps)"
                } else {
                    "FAIL (App installation not restricted in policies: $($failList -join ', '))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}