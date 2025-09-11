function Get-CISM365Control_2_1_14 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.1.14'
        Name        = 'Ensure alert policies are enabled in Microsoft 365 Defender'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Defender','SecurityCompliance')
        Description = @'
Ensure alert policies (for suspicious activity) are enabled in Microsoft 365 Defender to detect and respond to threats.
'@
        Rationale   = @'
Alert policies help security teams detect and respond to threats quickly.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/alert-policies?view=o365-worldwide'
        )
        Audit = {
            try {
                $policies = Get-ProtectionAlertPolicy
                $enabledPolicies = $policies | Where-Object { $_.Enabled -eq $true }
                if ($enabledPolicies.Count -gt 0) {
                    "PASS (Alert policies are enabled in Microsoft 365 Defender)"
                } else {
                    "FAIL (No alert policies are enabled in Microsoft 365 Defender)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}