function Get-CISM365Control_1_3_6 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.6'
        Name        = "Ensure the customer lockbox feature is enabled"
        Profile     = 'L2'
        Automated   = $false # Graph SecureScores endpoint does not reliably surface this setting
        Services    = @('AdminCenter','ExchangeOnline')
        Description = 'Customer Lockbox should be enabled to require approval for all Microsoft support data access requests.'
        Rationale   = 'Protects against unauthorized access by Microsoft support personnel.'
        References  = @(
            'https://learn.microsoft.com/en-us/azure/security/fundamentals/customer-lockbox-overview'
        )
        Audit = {
            try {
                $steps = @(
                    "Step 1: Review in Microsoft 365 admin center:",
                    "  1. Navigate to https://admin.microsoft.com/",
                    "  2. Expand Settings > Org settings > Security & privacy.",
                    "  3. Click Customer lockbox.",
                    "  4. Ensure 'Require approval for all data access requests' is checked.",
                    "",
                    "Step 2: Review in Exchange Online PowerShell:",
                    "  1. Connect using Connect-ExchangeOnline.",
                    "  2. Run: Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled",
                    "  3. Verify CustomerLockBoxEnabled is True."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Ensure Customer Lockbox feature is enabled per steps below.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}