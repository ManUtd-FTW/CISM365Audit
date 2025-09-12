function Get-CISM365Control_5_4_5 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.4.5'
        Name        = "Ensure account lockout threshold is configured"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "Account lockout threshold should be configured to prevent brute-force attacks."
        Rationale   = "Locking accounts after repeated failures prevents password guessing."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-password-ban-bad'
        )
        Audit       = {
            try {
                $settings = Get-MgDirectorySetting | Where-Object { $_.DisplayName -eq "PasswordProtection" }
                $threshold = $settings.Values | Where-Object { $_.Name -eq "LockoutThreshold" }
                if ($threshold.Value -and [int]$threshold.Value -le 10) {
                    "PASS (Account lockout threshold is configured: $($threshold.Value) attempts)"
                } else {
                    "FAIL (Account lockout threshold is not configured or is too high)"
                }
            }
            catch {
                "MANUAL (Unable to check account lockout threshold: $($_.Exception.Message))"
            }
        }
    }
}