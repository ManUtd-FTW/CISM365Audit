function Get-CISM365Control_1_1_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.4'
        Name        = "Ensure Guest Users are reviewed at least biweekly"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'Guest users should be reviewed regularly for proper access.'
        Rationale   = 'Periodic review limits risk from stale or unnecessary external access.'
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/identity-governance/access-reviews-overview'
        )
        Audit       = {
            try {
                $guests = Get-MgUser -All -Property UserType,UserPrincipalName | Where-Object { $_.UserType -eq "Guest" }
                if ($guests.Count -gt 0) {
                    "PASS (Guest users present:`n$($guests | Select-Object -ExpandProperty UserPrincipalName -join ', '))"
                } else {
                    "PASS (No guest users found)"
                }
            }
            catch {
                "MANUAL (Unable to enumerate guest users via Graph: $($_.Exception.Message))"
            }
        }
    }
}