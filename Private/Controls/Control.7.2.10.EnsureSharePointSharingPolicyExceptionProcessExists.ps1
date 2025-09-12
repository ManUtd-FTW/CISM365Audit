function Get-CISM365Control_7_2_10 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.10'
        Name        = "Ensure SharePoint sharing policy exception process exists"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('SharePointOnline')
        Description = "There must be a formal documented process for requesting and approving exceptions to SharePoint sharing policies."
        Rationale   = "Ensures exceptions are justified, tracked, and reviewed."
        References  = @(
            'https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off'
        )
        Audit       = @"
Manual Audit Steps:
1. Review documentation and workflows for sharing policy exceptions.
2. Interview site owners and admins about exception request/approval process.
3. Spot check exception requests for completeness and authorization.
"@
    }
}