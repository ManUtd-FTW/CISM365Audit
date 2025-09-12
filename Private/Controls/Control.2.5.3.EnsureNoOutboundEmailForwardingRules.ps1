function Get-CISM365Control_2_5_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.5.3'
        Name        = "Ensure transport rules do not allow forwarding to external domains"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Transport rules should not redirect or forward email to external domains, to prevent data exfiltration."
        Rationale   = "Blocking automatic forwarding mitigates risk of data leakage."
        References  = @(
            'https://learn.microsoft.com/en-us/exchange/security-and-compliance/mail-flow-rules/configuration-best-practices'
        )
        Audit       = {
            try {
                $rules = Get-TransportRule | Where-Object { $_.RedirectMessageTo -ne $null }
                $externalForwards = $rules | Where-Object {
                    ($_.RedirectMessageTo | Where-Object { $_ -notlike "*@yourdomain.com" })
                }
                if ($externalForwards.Count -eq 0) {
                    "PASS (No transport rules forward email to external domains)"
                } else {
                    "FAIL (Transport rules forward email to external domains: $($externalForwards | Select-Object -ExpandProperty Name -join ', '))"
                }
            }
            catch {
                "MANUAL (Unable to check transport rules for forwarding: $($_.Exception.Message))"
            }
        }
    }
}