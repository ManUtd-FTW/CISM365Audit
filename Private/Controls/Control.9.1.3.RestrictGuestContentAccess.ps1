function Get-CISM365Control_9_1_3 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '9.1.3'
        Name        = 'Ensure guest access to content is restricted'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Fabric','PowerBI')
        Description = @'
Restricts Azure AD B2B guest users from managing or editing content in the organization. Restrict guest access to a subset of the organization or disable it entirely.
'@
        Rationale   = @'
Enforcing security groups prevents unauthorized guest user access and upholds least privilege through RBAC.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/power-bi/admin/service-admin-portal-export-sharing'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Navigate to Microsoft Fabric https://app.powerbi.com/admin-portal",
                    "2. Select Tenant settings.",
                    "3. Scroll to Export and Sharing settings.",
                    "4. Ensure Allow Azure Active Directory guest users to edit and manage content in the organization is Disabled OR Enabled with specific security groups defined."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify guest user content access is restricted or disabled.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}