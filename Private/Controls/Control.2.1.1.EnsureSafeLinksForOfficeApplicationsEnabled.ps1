function Get-CISM365Control_2_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.1.1'
        Name        = "Ensure Safe Links for Office Applications is Enabled"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Safe Links policy for Office applications should be enabled for phishing protection."
        Rationale   = "Safe Links helps prevent access to malicious URLs in Office apps, emails, and Teams."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-links-policies-configure?view=o365-worldwide'
        )
        Audit       = {
            try {
                $policies = Get-SafeLinksPolicy
                $passPolicy = $policies | Where-Object {
                    $_.EnableSafeLinksForEmail -eq $true -and
                    $_.EnableSafeLinksForTeams -eq $true -and
                    $_.EnableSafeLinksForOffice -eq $true -and
                    $_.TrackClicks -eq $true -and
                    $_.AllowClickThrough -eq $false -and
                    $_.ScanUrls -eq $true -and
                    $_.EnableForInternalSenders -eq $true -and
                    $_.DeliverMessageAfterScan -eq $true -and
                    $_.DisableUrlRewrite -eq $false
                }
                if ($passPolicy) {
                    "PASS (Safe Links policy enabled for Office, Teams, and Email)"
                } else {
                    "FAIL (Safe Links policy not fully enabled or missing required settings)"
                }
            }
            catch {
                "MANUAL (Unable to check Safe Links policy: $($_.Exception.Message))"
            }
        }
    }
}