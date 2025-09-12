function Get-CISM365Control_6_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '6.1.1'
        Name        = "Ensure Microsoft 365 monitoring solution is enabled"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'Security')
        Description = "A monitoring solution (e.g., Microsoft Sentinel, Defender, or third-party SIEM) should be enabled and integrated with Microsoft 365."
        Rationale   = "Monitoring is essential for detecting threats and maintaining compliance."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/sentinel/connect-office-365',
            'https://learn.microsoft.com/en-us/microsoft-365/security/defender/microsoft-365-security-center'
        )
        Audit       = {
            try {
                $connector = Get-MgSecurityCloudAppSecurityConnector | Where-Object { $_.ProviderName -match "Microsoft 365" }
                if ($connector.Status -eq "enabled") {
                    "PASS (Microsoft 365 monitoring solution is enabled and integrated)"
                } else {
                    "FAIL (No enabled monitoring solution found for Microsoft 365)"
                }
            }
            catch {
                "MANUAL (Unable to check monitoring solution status: $($_.Exception.Message))"
            }
        }
    }
}