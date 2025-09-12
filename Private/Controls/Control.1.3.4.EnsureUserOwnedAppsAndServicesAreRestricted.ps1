function Get-CISM365Control_1_3_4 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.4'
        Name        = "Ensure 'User owned apps and services' is restricted"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('AdminCenter')
        Description = 'Do not allow users to install add-ins in Word, Excel, or PowerPoint via the Office Store.'
        Rationale   = 'Restricts attack surface from add-ins and user-started trials.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/admin/manage/manage-user-owned-apps-and-services?view=o365-worldwide'
        )
        Audit = {
            try {
                $steps = @(
                    "Step 1: Review settings in the UI:",
                    "  1. Navigate to Microsoft 365 admin center: https://admin.microsoft.com/",
                    "  2. Expand Settings > Org settings > Services > User owned apps and services.",
                    "  3. Verify 'Let users access the Office Store' and 'Let users start trials on behalf of your organization' are NOT checked."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Ensure user owned apps and services are restricted per steps below.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}