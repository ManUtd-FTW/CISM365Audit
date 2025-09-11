# Control: 2.1.4 Ensure Safe Attachments policy is enabled (L2)
# Requires: Exchange Online (Safe Attachments policy/rule cmdlets)
function Get-CISM365Control_2_1_4 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.1.4'
        Name        = 'Ensure Safe Attachments policy is enabled'
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Exchange')
        Description = 'Verify that Safe Attachments protection is in effect via at least one enabled Safe Attachments rule with a policy that blocks (or dynamically delivers) malicious attachments.'
        Rationale   = 'Safe Attachments detonates attachments in a virtual environment to detect unknown malware before delivery, reducing infection risk from email-borne threats.'
        References  = @(
            'https://learn.microsoft.com/powershell/module/exchangepowershell/get-safeattachmentpolicy?view=exchange-ps',
            'https://learn.microsoft.com/powershell/module/exchangepowershell/get-safeattachmentrule?view=exchange-ps',
            'https://learn.microsoft.com/defender-office-365/safe-attachments-policies-configure',
            'https://learn.microsoft.com/defender-office-365/safe-attachments-about'
        )
        Audit = {
            try {
                # Lazy-load helper if not already loaded (module bootstrap normally provides it)
                try {
                    if (-not (Get-Command -Name Get-CurrentTenant -ErrorAction SilentlyContinue)) {
                        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
                        $candidate = Join-Path $scriptDir '..\..\Helpers\Get-CurrentTenant.ps1'
                        $resolved = Resolve-Path -Path $candidate -ErrorAction SilentlyContinue
                        if ($resolved) { . $resolved.ProviderPath }
                    }
                } catch {}

                # Ensure required Exchange cmdlets exist
                if (-not (Get-Command -Name Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue) -or
                    -not (Get-Command -Name Get-SafeAttachmentRule -ErrorAction SilentlyContinue)) {
                    return 'MANUAL: Safe Attachments cmdlets are unavailable in this session. Connect to Exchange Online (Connect-ExchangeOnline) or run from a session with Exchange cmdlets.'
                }

                # Gather enabled rules (defensive)
                $enabledRules = Get-SafeAttachmentRule -State Enabled -ErrorAction SilentlyContinue
                if (-not $enabledRules -or $enabledRules.Count -eq 0) {
                    # No enabled rules found — tenant may rely on global/preset policies; require manual verification
                    return 'MANUAL (No enabled Safe Attachments rules found; tenant may rely on Preset Security Policies—verify coverage in the Defender portal)'
                }

                $policiesByName = @{}
                $issues = New-Object System.Collections.Generic.List[string]
                $compliant = New-Object System.Collections.Generic.List[string]

                foreach ($r in $enabledRules) {
                    # Each rule should point to a SafeAttachmentPolicy by name
                    $pname = $r.SafeAttachmentPolicy
                    if ([string]::IsNullOrWhiteSpace($pname)) {
                        $issues.Add("Rule '$($r.Name)' has no associated SafeAttachmentPolicy")
                        continue
                    }

                    if (-not $policiesByName.ContainsKey($pname)) {
                        try {
                            $policiesByName[$pname] = Get-SafeAttachmentPolicy -Identity $pname -ErrorAction SilentlyContinue
                        } catch {
                            $policiesByName[$pname] = $null
                        }
                    }

                    $p = $policiesByName[$pname]
                    if (-not $p) {
                        # Missing policy is considered non-compliant (FAIL), not MANUAL
                        $issues.Add("Rule '$($r.Name)' references missing policy '$pname'")
                        continue
                    }

                    # Some tenants expose .Enable; treat missing property as enabled to avoid false MANUALs
                    $enabledProp = $true
                    if ($p.PSObject.Properties.Name -contains 'Enable') { $enabledProp = [bool]$p.Enable }

                    $action = $null
                    if ($p.PSObject.Properties.Name -contains 'Action') { $action = $p.Action } else {
                        # fallback if property name differs
                        $action = $p.Action 2>$null
                    }

                    $isEnforcing = $false
                    if ($action) {
                        $isEnforcing = $action -in 'Block','DynamicDelivery','Replace'
                    }

                    if (-not $enabledProp -or -not $isEnforcing) {
                        $why = @()
                        if (-not $enabledProp) { $why += 'policy disabled' }
                        if (-not $isEnforcing) { $why += "policy action=$action (expected Block/DynamicDelivery/Replace)" }
                        $issues.Add("Rule '$($r.Name)' -> Policy '$pname' noncompliant: $($why -join '; ')")
                    } else {
                        $compliant.Add("Rule '$($r.Name)' -> Policy '$pname' action=$action")
                    }
                }

                # Final decision:
                if ($issues.Count -eq 0 -and $compliant.Count -gt 0) {
                    return "PASS: Compliant Safe Attachments in effect: $($compliant -join ' | ')"
                }

                # Any issue (including missing policies) results in FAIL
                if ($issues.Count -gt 0) {
                    if ($compliant.Count -gt 0) {
                        return "FAIL: Mixed results. Compliant: $($compliant -join ' | '). Issues: $($issues -join ' | ')"
                    } else {
                        return "FAIL: No compliant Safe Attachments policy/rule combination found. Issues: $($issues -join ' | ')"
                    }
                }

                # Shouldn't reach here, but return MANUAL defensively
                return 'MANUAL: Unable to determine Safe Attachments compliance (unexpected state)'
            } catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}