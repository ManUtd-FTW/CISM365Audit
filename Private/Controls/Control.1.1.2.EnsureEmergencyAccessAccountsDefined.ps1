function Get-CISM365Control_1_1_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.2'
        Name        = "Ensure two emergency access accounts have been defined"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'There should be at least two unlicensed, cloud-only, .onmicrosoft.com domain Global Admin accounts for emergency access ("break glass" accounts).'
        Rationale   = 'Emergency access accounts ensure recovery in case of total lockout or MFA failure.'
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/roles/security-emergency-access'
        )
        Audit       = {
            try {
                $role = Get-MgDirectoryRole | Where-Object { $_.RoleTemplateId -eq "62e90394-69f5-4237-9190-012177145e10" }
                if (-not $role) { return "MANUAL (Global Admin role object not found via Graph)" }
                $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
                $breakGlass = $members | Where-Object {
                    ($_.UserPrincipalName -like "*.onmicrosoft.com") -and
                    (-not $_.AssignedLicenses) -and
                    (-not $_.OnPremisesSyncEnabled)
                }
                if ($breakGlass.Count -ge 2) {
                    "PASS ($($breakGlass.Count) emergency access accounts found: $($breakGlass | Select-Object -ExpandProperty UserPrincipalName -join ', '))"
                } else {
                    "FAIL (Less than two emergency access accounts found)"
                }
            }
            catch {
                "MANUAL (Unable to enumerate emergency access accounts: $($_.Exception.Message))"
            }
        }
    }
}