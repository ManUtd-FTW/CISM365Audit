function Get-CISM365Control_7_2_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.5'
        Name        = "Ensure SharePoint guest users cannot share items they don't own"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('SharePoint')
        Description = @'
Prevents guest users from re-sharing content they do not own in SharePoint.
'@
        Rationale   = @'
Owners should retain authority over external sharing to prevent unauthorized disclosures.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off',
            'https://learn.microsoft.com/en-us/sharepoint/external-sharing-overview'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.PreventExternalUsersFromResharing -eq $true) {
                    "PASS (Guests cannot reshare items they don't own)"
                } else {
                    "FAIL (Guests can reshare items they don't own)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}