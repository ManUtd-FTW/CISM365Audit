function Get-CISM365Control_7_2_10 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '7.2.10'
        Name        = "Ensure reauthentication with verification code is restricted"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('SharePoint','OneDrive')
        Description = @'
Configures frequency for guests using verification codes to access SharePoint or OneDrive. Recommended: 15 days or less.
'@
        Rationale   = @'
Frequent reauthentication ensures guest access is not prolonged and helps secure shared resources.
'@
        References  = @(
            'https://learn.microsoft.com/en-US/sharepoint/what-s-new-in-sharing-in-targeted-release?WT.mc_id=365AdminCSH_spo',
            'https://learn.microsoft.com/en-US/sharepoint/turn-external-sharing-on-or-off?WT.mc_id=365AdminCSH_spo#change-the-organization-level-external-sharing-setting',
            'https://learn.microsoft.com/en-us/azure/active-directory/external-identities/one-time-passcode'
        )
        Audit = {
            try {
                $tenant = Get-SPOTenant
                if ($tenant.EmailAttestationRequired -eq $true -and $tenant.EmailAttestationReAuthDays -le 15) {
                    "PASS (Verification code reauthentication required every $($tenant.EmailAttestationReAuthDays) days)"
                } else {
                    "FAIL (Verification code reauthentication not properly configured: Required=$($tenant.EmailAttestationRequired), Days=$($tenant.EmailAttestationReAuthDays))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}