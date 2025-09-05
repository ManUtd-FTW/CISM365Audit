# Control: 2.1.9 Ensure that DKIM is enabled for all Exchange Online domains (L1)
# Requires: Exchange Online (Get-AcceptedDomain / Get-DkimSigningConfig)
function Get-CISM365Control_2_1_9 {
  [OutputType([hashtable])]
  param()
  @{
    Id = '2.1.9'
    Name = 'Ensure that DKIM is enabled for all Exchange Online domains'
    Profile = 'L1'
    Automated = $true
    Services = @('ExchangeOnline')
    Description = 'DKIM should be enabled for all custom accepted domains (non-onmicrosoft.com).'
    Rationale = 'DKIM helps prevent spoofing by cryptographically signing outbound mail.'
    References = @(
      # Get-DkimSigningConfig documentation
      'https://learn.microsoft.com/powershell/module/exchangepowershell/get-dkimsigningconfig?view=exchange-ps'
    )
    Audit = {
      try {
        $domains = Get-AcceptedDomain -ErrorAction Stop | Where-Object {
          $_.DomainType -eq 'Authoritative' -and $_.DomainName -notlike '*.onmicrosoft.com'
        }
        if (-not $domains) { return 'MANUAL (No custom authoritative domains found)' }

        $notEnabled = @()
        foreach ($d in $domains) {
          try {
            $dk = Get-DkimSigningConfig -Identity $d.DomainName -ErrorAction Stop
            if (-not $dk.Enabled) { $notEnabled += $d.DomainName }
          } catch {
            # No config found or lookup failed → treat as not enabled
            $notEnabled += $d.DomainName
          }
        }

        if ($notEnabled.Count -eq 0) {
          'PASS (DKIM enabled on all custom domains)'
        } else {
          "FAIL (DKIM not enabled on: $($notEnabled -join ', '))"
        }
      } catch {
        "ERROR: $($_.Exception.Message)"
      }
    }
  }
}
