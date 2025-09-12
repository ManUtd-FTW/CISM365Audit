function Get-CISM365Control_6_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.3.1'
        Name        = "Ensure threat intelligence integration is enabled (ExchangeOnline)"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Threat intelligence (e.g., ATP Safe Links, Safe Attachments) should be enabled for Exchange Online to detect emerging threats."
        Rationale   = "Threat intelligence feeds and ATP features strengthen defense against evolving threats."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-links?view=o365-worldwide',
            'https://learn.microsoft.com/en-us/powershell/module/exchange/set-safelinkspolicy?view=exchange-ps'
        )
        Audit       = {
            try {
                $safeLinks = Get-SafeLinksPolicy | Where-Object { $_.IsEnabled -eq $true }
                $safeAttachments = Get-SafeAttachmentPolicy | Where-Object { $_.IsEnabled -eq $true }
                if ($safeLinks -and $safeAttachments) {
                    "PASS (Threat intelligence features (Safe Links/Safe Attachments) are enabled)"
                } else {
                    "FAIL (Threat intelligence features are NOT fully enabled)"
                }
            }
            catch {
                "MANUAL (Unable to check threat intelligence features: $($_.Exception.Message))"
            }
        }
    }
}