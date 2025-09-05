# Control: 2.1.4 Ensure Safe Attachments policy is enabled (L2)
# Requires: Exchange Online (Safe Attachments policy/rule cmdlets)
function Get-CISM365Control_2_1_4 {
  [OutputType([hashtable])]
  param()
  @{
    Id = '2.1.4'
    Name = 'Ensure Safe Attachments policy is enabled'
    Profile = 'L2'
    Automated = $true
    Services = @('ExchangeOnline')
    Description = 'Verify that Safe Attachments protection is in effect via at least one enabled Safe Attachments rule with a policy that blocks (or dynamically delivers) malicious attachments.'
    Rationale = 'Safe Attachments detonates attachments in a virtual environment to detect unknown malware before delivery, reducing infection risk from email-borne threats.'
    References = @(
      # Cmdlets and product behavior
      'https://learn.microsoft.com/powershell/module/exchangepowershell/get-safeattachmentpolicy?view=exchange-ps',
      'https://learn.microsoft.com/powershell/module/exchangepowershell/get-safeattachmentrule?view=exchange-ps',
      # Configuration & presets background
      'https://learn.microsoft.com/defender-office-365/safe-attachments-policies-configure',
      'https://learn.microsoft.com/defender-office-365/safe-attachments-about'
    )
    Audit = {
      try {
        # Ensure the cmdlets exist in the current session
        if (-not (Get-Command Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue) -or
            -not (Get-Command Get-SafeAttachmentRule   -ErrorAction SilentlyContinue)) {
          return 'MANUAL (Safe Attachments cmdlets are unavailable in this session)'
        }

        # Gather enabled rules
        $enabledRules = Get-SafeAttachmentRule -State Enabled -ErrorAction Stop
        $policiesByName = @{}
        $issues = @()
        $compliant = @()

        foreach ($r in $enabledRules) {
          # Each rule points to a SafeAttachmentPolicy by name
          $pname = $r.SafeAttachmentPolicy
          if ([string]::IsNullOrWhiteSpace($pname)) {
            $issues += "Rule '$($r.Name)' has no associated SafeAttachmentPolicy"
            continue
          }

          if (-not $policiesByName.ContainsKey($pname)) {
            try {
              $policiesByName[$pname] = Get-SafeAttachmentPolicy -Identity $pname -ErrorAction Stop
            } catch {
              $policiesByName[$pname] = $null
            }
          }

          $p = $policiesByName[$pname]
          if (-not $p) {
            $issues += "Rule '$($r.Name)' references missing policy '$pname'"
            continue
          }

          # Some tenants expose .Enable; treat missing property as enabled to avoid false MANUAL.
          $enabledProp = $true
          if ($p.PSObject.Properties.Name -contains 'Enable') { $enabledProp = [bool]$p.Enable }

          # Valid Safe Attachments actions (Block recommended by CIS; DynamicDelivery/Replace also enforce)
          $action = $p.Action
          $isEnforcing = $action -in 'Block','DynamicDelivery','Replace'

          if (-not $enabledProp -or -not $isEnforcing) {
            $why = @()
            if (-not $enabledProp) { $why += 'policy disabled' }
            if (-not $isEnforcing) { $why += "policy action=$action (expected Block/DynamicDelivery/Replace)" }
            $issues += "Rule '$($r.Name)' -> Policy '$pname' noncompliant: $($why -join '; ')"
          } else {
            $compliant += "Rule '$($r.Name)' -> Policy '$pname' action=$action"
          }
        }

        # If we found no enabled rules at all, consider preset policies possibility
        if (-not $enabledRules -or $enabledRules.Count -eq 0) {
          return 'MANUAL (No enabled Safe Attachments rules found; tenant may rely on Preset Security Policies—verify coverage in the Defender portal)'
        }

        if ($compliant.Count -gt 0 -and $issues.Count -eq 0) {
          "PASS (Compliant Safe Attachments in effect: $($compliant -join ' | '))"
        } elseif ($compliant.Count -gt 0 -and $issues.Count -gt 0) {
          "FAIL (Mixed results. Compliant: $($compliant -join ' | '). Issues: $($issues -join ' | '))"
        } else {
          "FAIL (No compliant Safe Attachments policy/rule combination found. Issues: $($issues -join ' | '))"
        }
      } catch {
        "ERROR: $($_.Exception.Message)"
      }
    }
  }
}
