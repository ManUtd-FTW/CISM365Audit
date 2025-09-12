function Get-CISM365Control_2_1_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.1.5'
        Name        = "Ensure Safe Attachments for SharePoint, OneDrive, and Teams is Enabled"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Defender for Office 365 Safe Attachments must be enabled for SharePoint, OneDrive, and Teams, with Safe Documents enabled and click-through disabled."
        Rationale   = "Blocks malicious files in SharePoint, OneDrive, Teams, and Office clients."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-attachments-for-spo-odfb-teams-configure?view=o365-worldwide'
        )
        Audit       = {
            try {
                $policy = Get-AtpPolicyForO365
                if ($policy.EnableATPForSPOTeamsODB -and $policy.EnableSafeDocs -and (-not $policy.AllowSafeDocsOpen)) {
                    "PASS (Safe Attachments for SPO/Teams/ODB is enabled and SafeDocs enforced)"
                } else {
                    "FAIL (Safe Attachments for SPO/Teams/ODB not fully enabled or SafeDocs not enforced)"
                }
            }
            catch {
                "MANUAL (Unable to check Safe Attachments policy for SharePoint/OneDrive/Teams: $($_.Exception.Message))"
            }
        }
    }
}