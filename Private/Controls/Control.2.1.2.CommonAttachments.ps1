function Get-CISM365Control_2_1_2 {
    [OutputType([hashtable])]
    param()
    @{
        Id          = '2.1.2'
        Name        = 'Ensure the Common Attachment Types Filter is enabled'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Exchange','Defender')
        Description = 'Verify the Common Attachment Types Filter (EnableFileFilter) is enabled on the malware filter policy (Default or highest priority policy).'
        Rationale   = 'Blocking known malicious attachment types helps prevent malware from being delivered via email.'
        References  = @(
            'https://learn.microsoft.com/en-us/powershell/module/exchange/getmalwarefilterpolicy?view=exchange-ps',
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/antimalware-policies-configure?view=o365-worldwide'
        )
        Audit = {
            try {
                # Defensive centralized helper fallback
                try {
                    if (-not (Get-Command -Name Get-CurrentTenant -ErrorAction SilentlyContinue)) {
                        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
                        $candidate = Join-Path $scriptDir '..\..\Helpers\Get-CurrentTenant.ps1'
                        $resolved = Resolve-Path -Path $candidate -ErrorAction SilentlyContinue
                        if ($resolved) { . $resolved.ProviderPath }
                    }
                } catch {}

                # Required cmdlet
                if (-not (Get-Command -Name Get-MalwareFilterPolicy -ErrorAction SilentlyContinue)) {
                    return "MANUAL: Required Exchange cmdlet 'Get-MalwareFilterPolicy' is not available in this session. Connect to Exchange Online (Connect-ExchangeOnline) or run from a session with the Exchange module loaded."
                }

                # Query malware filter policies
                try {
                    $policies = Get-MalwareFilterPolicy -ErrorAction SilentlyContinue
                } catch {
                    return "ERROR: Failed to query malware filter policies: $($_.Exception.Message)"
                }

                if (-not $policies -or $policies.Count -eq 0) {
                    return "MANUAL: No malware filter policies found; verify policies exist in Microsoft 365 Defender or create one as recommended."
                }

                # Prefer Default policy if present, otherwise use highest priority if Priority is available, else pick first
                $selectedPolicy = $null
                $default = $policies | Where-Object { $_.Name -eq 'Default' } | Select-Object -First 1
                if ($default) {
                    $selectedPolicy = $default
                } else {
                    if ($policies[0].PSObject.Properties.Name -contains 'Priority') {
                        $selectedPolicy = $policies | Sort-Object @{Expression={ if ($_.Priority -ne $null) { [int]$_.Priority } else { 999999 } }} | Select-Object -First 1
                    } else {
                        $selectedPolicy = $policies | Select-Object -First 1
                    }
                }

                if ($null -eq $selectedPolicy) {
                    return "MANUAL: Unable to determine a malware filter policy to evaluate."
                }

                $policyName = $selectedPolicy.Name

                # Inspect EnableFileFilter property
                $propName = 'EnableFileFilter'
                $value = $null
                if ($selectedPolicy.PSObject.Properties.Name -contains $propName) {
                    $value = $selectedPolicy.$propName
                } else {
                    try { $value = $selectedPolicy.$propName } catch { $value = $null }
                }

                if ($null -eq $value) {
                    return ("MANUAL: Policy '{0}' does not expose '{1}' property; verify setting in the admin UI: Policies & rules → Threat policies → Anti-malware → {0}." -f $policyName, $propName)
                }

                # Normalize and evaluate boolean
                if ($value -is [string]) {
                    $parsed = $null
                    if ([bool]::TryParse($value, [ref]$parsed)) { $value = $parsed }
                }

                if ($value -eq $true) {
                    return ("PASS: '{0}' has EnableFileFilter = True." -f $policyName)
                } else {
                    return ("FAIL: '{0}' has EnableFileFilter = {1} (expected True). Enable via Set-MalwareFilterPolicy -Identity {0} -EnableFileFilter $true or update the policy in Microsoft 365 Defender." -f $policyName, $value)
                }
            } catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}