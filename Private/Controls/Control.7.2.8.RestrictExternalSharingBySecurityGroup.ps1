function Get-CISM365Control_7_2_8 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '7.2.8'
        Name        = "Ensure external sharing is restricted by security group"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePoint','OneDrive')
        Description = @'
Restricts external sharing of content to specific security groups globally.
'@
        Rationale   = @'
Enforces role-based access control for external sharing using security groups.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/manage-security-groups'
        )
        Audit = {
            try {
                $steps = @(
                    "UI:",
                    "1. SharePoint admin center > Policies > Sharing.",
                    "2. Expand More external sharing settings.",
                    "3. Verify 'Allow only users in specific security groups to share externally' is checked and groups are defined."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify external sharing is restricted by security group in SharePoint and OneDrive.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}