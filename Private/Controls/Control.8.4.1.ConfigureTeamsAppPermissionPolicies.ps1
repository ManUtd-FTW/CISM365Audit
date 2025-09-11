function Get-CISM365Control_8_4_1 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '8.4.1'
        Name        = "Ensure app permission policies are configured"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Teams')
        Description = @'
App permission policies control which classes of apps users can install in Teams. Only approved apps should be allowed.
'@
        Rationale   = @'
Allowing only approved apps reduces risk of introducing malicious software.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/step-by-step-guides/reducing-attack-surface-in-microsoft-teams?view=o365-worldwide#disabling-third-party--custom-apps',
            'https://learn.microsoft.com/en-us/microsoftteams/teams-app-permission-policies'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Teams admin center > Teams apps > Permission policies.",
                    "2. Click Global (Org-wide default).",
                    "3. Microsoft apps: Allow all apps.",
                    "4. Third-party apps: Block all OR allow specific apps only.",
                    "5. Custom apps: Block all OR allow specific apps only."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify Teams app permission policies are configured to restrict apps appropriately.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}