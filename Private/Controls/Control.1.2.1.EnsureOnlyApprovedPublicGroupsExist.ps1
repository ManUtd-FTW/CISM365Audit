function Get-CISM365Control_1_2_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.2.1'
        Name        = "Ensure only organizationally managed/approved public groups exist"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Graph')
        Description = 'Only organizationally approved public groups should exist; all others should be private.'
        Rationale   = 'Restricts broad data access to only approved groups.'
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-self-service-management'
        )
        Audit       = {
            try {
                $publicGroups = Get-MgGroup -All | Where-Object { $_.Visibility -eq "Public" }
                if ($publicGroups.Count -eq 0) {
                    "PASS (No public groups exist)"
                } else {
                    $groupNames = $publicGroups | Select-Object -ExpandProperty DisplayName
                    "FAIL (The following public groups exist: $($groupNames -join ', '))"
                }
            }
            catch {
                "MANUAL (Unable to enumerate Microsoft 365 Groups: $($_.Exception.Message))"
            }
        }
    }
}