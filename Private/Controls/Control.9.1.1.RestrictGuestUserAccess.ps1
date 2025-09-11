function Get-CISM365Control_9_1_1 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '9.1.1'
        Name        = 'Ensure guest user access is restricted'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Fabric','PowerBI')
        Description = @'
This setting allows business-to-business (B2B) guests access to Microsoft Fabric and contents they have permissions to. Restrict guest access to a subset of the organization or disable it entirely.
'@
        Rationale   = @'
Enforcing security groups prevents unauthorized guest access to Microsoft Fabric and upholds least privilege, using role-based access control.
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
                    "4. Ensure Allow Azure Active Directory guest users to access Microsoft Fabric is Disabled OR Enabled with specific security groups defined."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify guest user access to Microsoft Fabric is restricted or disabled.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}