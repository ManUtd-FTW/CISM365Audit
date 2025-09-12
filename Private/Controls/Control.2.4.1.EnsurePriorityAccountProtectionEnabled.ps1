function Get-CISM365Control_2_4_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.4.1'
        Name        = "Ensure Priority account protection is enabled and configured"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender', 'AdminCenter')
        Description = "Priority account protection should be enabled in Defender, and priority accounts tagged accordingly."
        Rationale   = "Priority accounts (executives, admins, etc.) require extra protection against targeted attacks."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/admin/setup/priority-accounts'
        )
        Audit       = @"
Manual Audit Steps:
1. Go to https://admin.microsoft.com > Health > Priority accounts (or search 'Priority accounts').
2. Verify that priority account protection is enabled.
3. Check that all relevant accounts (executives, admins) are tagged as priority accounts.
4. Confirm those accounts have Defender protection enabled and appropriate alerting configured.
"@
    }
}