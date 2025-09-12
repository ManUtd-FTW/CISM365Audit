function Get-CISM365Control_1_4_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.4.1'
        Name        = "Ensure dormant or disabled accounts are inventoried and reviewed"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = "All disabled (and enabled) accounts should be inventoried. Disabled accounts must be reviewed and removed if unnecessary."
        Rationale   = "Reviewing dormant/disabled accounts is essential to prevent unauthorized access and maintain a secure user inventory."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/security-operations-user-accounts',
            'https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final'
        )
        Audit       = {
            try {
                $users = Get-MgUser -All -Property UserPrincipalName,AccountEnabled
                if (-not $users) { return 'MANUAL (Unable to enumerate users via Graph)' }
                $disabled = $users | Where-Object { $_.AccountEnabled -eq $false }
                $enabled = $users | Where-Object { $_.AccountEnabled -eq $true }
                $resultSummary = "PASS (Disabled accounts: $($disabled.Count); Enabled accounts: $($enabled.Count))"
                if ($disabled.Count -gt 0) {
                    $resultSummary += "`nDisabled accounts:`n$($disabled | Select-Object -ExpandProperty UserPrincipalName -join "`n")"
                }
                $resultSummary
            }
            catch {
                "MANUAL (Unable to check user account status via Graph: $($_.Exception.Message))"
            }
        }
    }
}