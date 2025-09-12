function Get-CISM365Control_1_4_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.4.3'
        Name        = "Ensure 'UserType' attribute is correct for all users"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Inventory all users and confirm 'UserType' is set correctly to 'Member' or 'Guest', as appropriate."
        Rationale   = "Ensuring correct UserType assignment helps maintain least privilege, proper access reviews, and regulatory compliance."
        References  = @(
            'https://learn.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0',
            'https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final'
        )
        Audit       = {
            try {
                $users = Get-MgUser -All -Property UserPrincipalName,UserType
                if (-not $users) { return 'MANUAL (Unable to enumerate users via Graph)' }
                $guests = $users | Where-Object { $_.UserType -eq "Guest" }
                $members = $users | Where-Object { $_.UserType -eq "Member" }
                $otherTypes = $users | Where-Object { $_.UserType -notin @("Guest","Member") }
                $summary = "PASS (Guests: $($guests.Count), Members: $($members.Count))"
                if ($otherTypes.Count -gt 0) {
                    $summary = "FAIL (Users found with unexpected UserType: $($otherTypes | Select-Object -ExpandProperty UserPrincipalName -join ', '))"
                }
                $summary
            }
            catch {
                "MANUAL (Unable to check user types via Graph: $($_.Exception.Message))"
            }
        }
    }
}