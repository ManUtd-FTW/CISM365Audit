function Get-CISM365Control_1_3_3 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.3'
        Name        = "Ensure 'External sharing' of calendars is not available"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('ExchangeOnline')
        Description = 'External calendar sharing should be disabled for all users.'
        Rationale   = 'Prevents attackers or unauthorized parties from learning about organizational relationships and schedules.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/admin/manage/share-calendars-with-external-users?view=o365-worldwide'
        )
        Audit = {
            try {
                $steps = @(
                    "Step 1: Ensure calendar details sharing with external users is disabled:",
                    "  1. Navigate to Microsoft 365 admin center: https://admin.microsoft.com/",
                    "  2. Expand Settings > Org settings > Services > Calendar.",
                    "  3. Verify 'Let your users share their calendars with people outside of your organization who have Office 365 or Exchange' is unchecked.",
                    "",
                    "Step 2: Review using PowerShell:",
                    "  1. Connect using Connect-ExchangeOnline.",
                    "  2. Run:",
                    "     Get-SharingPolicy | Where-Object { $_.Domains -like '*CalendarSharing*' }",
                    "  3. Verify Enabled is set to False."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Ensure calendar external sharing is disabled as described below.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}