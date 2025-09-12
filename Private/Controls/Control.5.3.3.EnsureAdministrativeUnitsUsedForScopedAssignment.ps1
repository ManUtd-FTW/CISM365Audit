function Get-CISM365Control_5_3_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.3.3'
        Name        = "Ensure administrative units are used for scoped policy assignment"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Graph')
        Description = "Administrative Units should exist and be used to scope policy and role assignments."
        Rationale   = "Limiting scope using admin units reduces risk of broad misconfiguration."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/roles/administrative-units'
        )
        Audit       = {
            try {
                $units = Get-MgAdministrativeUnit
                $assigned = $units | Where-Object { $_.Members.Count -gt 0 }
                if ($assigned.Count -gt 0) {
                    "PASS (Administrative units exist and have assigned members)"
                } else {
                    "FAIL (No administrative units with assigned members found)"
                }
            }
            catch {
                "MANUAL (Unable to check administrative units: $($_.Exception.Message))"
            }
        }
    }
}