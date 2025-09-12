function Get-CISM365Control_1_1_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.3'
        Name        = "Ensure between two and four global admins are designated"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'There should be at least two, but no more than four Global Administrators assigned.'
        Rationale   = 'Reduces risk of malicious activity and ensures redundancy.'
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#role-template-ids'
        )
        Audit       = {
            try {
                $role = Get-MgDirectoryRole | Where-Object { $_.RoleTemplateId -eq "62e90394-69f5-4237-9190-012177145e10" }
                if (-not $role) { return "MANUAL (Global Admin role object not found via Graph)" }
                $admins = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
                if ($admins.Count -ge 2 -and $admins.Count -le 4) {
                    "PASS ($($admins.Count) Global Administrators found)"
                } else {
                    "FAIL ($($admins.Count) Global Administrators assigned; must be 2–4)"
                }
            }
            catch {
                "MANUAL (Unable to enumerate Global Administrators: $($_.Exception.Message))"
            }
        }
    }
}