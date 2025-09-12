function Get-CISM365Control_7_2_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.2'
        Name        = "Ensure SharePoint access requests are reviewed"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "Access requests for SharePoint sites should be logged and periodically reviewed by site owners."
        Rationale   = "Reviewing access requests helps ensure only authorized users gain access."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/manage-site-collection-access-requests'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to a SharePoint site > Site Settings > Site Permissions.
2. Click 'Access Request Settings'.
3. Verify requests are sent to responsible owners and are being reviewed.
4. Review the access request history/log for unauthorized approvals.
"@
    }
}