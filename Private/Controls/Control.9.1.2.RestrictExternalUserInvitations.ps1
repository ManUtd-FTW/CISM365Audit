function Get-CISM365Control_9_1_2 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '9.1.2'
        Name        = 'Ensure external user invitations are restricted'
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Fabric','PowerBI')
        Description = @'
Controls whether new external users can be invited to the organization through Power BI sharing, permissions, and subscription experiences.
'@
        Rationale   = @'
Restricting invitations prevents unauthorized access and enforces least privilege through role-based access control.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/power-bi/admin/service-admin-portal-export-sharing',
            'https://learn.microsoft.com/en-us/power-bi/enterprise/service-admin-azure-ad-b2b#invite-guest-users'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Navigate to Microsoft Fabric https://app.powerbi.com/admin-portal",
                    "2. Select Tenant settings.",
                    "3. Scroll to Export and Sharing settings.",
                    "4. Ensure Invite external users to your organization is Disabled OR Enabled with specific security groups defined."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify external user invitations are restricted or disabled.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}