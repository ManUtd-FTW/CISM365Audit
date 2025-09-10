function Get-CISM365Control_2_1_7 {
    [OutputType([hashtable])]
    param()

    return @{
        Id        = '2.1.7'
        Name      = 'Ensure that an anti-phishing policy has been created'
        Profile   = 'L1'
        Automated = $true
        Services  = @('ExchangeOnline')
        Description = @'
Verify that an anti-phishing policy (for example the Office365 AntiPhish Default policy) exists and is enabled with reasonable protections enabled (PhishThresholdLevel >= 2, mailbox intelligence and spoof intelligence enabled).
'@
        Rationale = 'Anti-phishing policies increase detection and protection against impersonation and spoofing attacks.'
        References = @(
            'https://learn.microsoft.com/microsoft-365/security/office-365-security/anti-phish-policies'
        )
        Audit = {
            try {
                # Ensure required Exchange cmdlet is available in the session
                if (-not (Get-Command -Name Get-AntiPhishPolicy -ErrorAction SilentlyContinue)) {
                    return "MANUAL (Get-AntiPhishPolicy cmdlet is not available in this session. Install/enable the ExchangeOnlineManagement module and Connect-ExchangeOnline and re-run.)"
                }

                # Helper: case-insensitive property getter
                function Get-PropValue {
                    param($obj, $name)
                    $p = $obj.PSObject.Properties | Where-Object { $_.Name -ieq $name }
                    if ($p) { return $p.Value }
                    return $null
                }

                $policies = Get-AntiPhishPolicy -ErrorAction Stop

                if (-not $policies -or $policies.Count -eq 0) {
                    return "MANUAL (No anti-phish policies returned by Get-AntiPhishPolicy; verify connectivity and permissions.)"
                }

                # Evaluate one policy object for compliance
                function Evaluate-Policy {
                    param($policy)
                    $issues = @()

                    $enabled = Get-PropValue -obj $policy -name 'Enabled'
                    if ($enabled -eq $null) { $issues += "Missing property 'Enabled' on policy '$($policy.Name)'" }
                    elseif (-not [bool]$enabled) { $issues += "Enabled = $enabled (expected True)" }

                    $phishLevel = Get-PropValue -obj $policy -name 'PhishThresholdLevel'
                    if ($phishLevel -eq $null) { $issues += "Missing property 'PhishThresholdLevel' on policy '$($policy.Name)'" }
                    else {
                        # Try numeric comparison
                        try { $level = [int]$phishLevel } catch { $level = -1 }
                        if ($level -lt 2) { $issues += "PhishThresholdLevel = $phishLevel (expected >= 2 - Aggressive)" }
                    }

                    $mbIntProt = Get-PropValue -obj $policy -name 'EnableMailboxIntelligenceProtection'
                    if ($mbIntProt -eq $null) { $issues += "Missing property 'EnableMailboxIntelligenceProtection' on policy '$($policy.Name)'" }
                    elseif (-not [bool]$mbIntProt) { $issues += "EnableMailboxIntelligenceProtection = $mbIntProt (expected True)" }

                    $mbInt = Get-PropValue -obj $policy -name 'EnableMailboxIntelligence'
                    if ($mbInt -eq $null) { $issues += "Missing property 'EnableMailboxIntelligence' on policy '$($policy.Name)'" }
                    elseif (-not [bool]$mbInt) { $issues += "EnableMailboxIntelligence = $mbInt (expected True)" }

                    $spoofInt = Get-PropValue -obj $policy -name 'EnableSpoofIntelligence'
                    if ($spoofInt -eq $null) { $issues += "Missing property 'EnableSpoofIntelligence' on policy '$($policy.Name)'" }
                    elseif (-not [bool]$spoofInt) { $issues += "EnableSpoofIntelligence = $spoofInt (expected True)" }

                    return [pscustomobject]@{
                        Policy    = $policy
                        Issues    = $issues
                        Compliant = ($issues.Count -eq 0)
                    }
                }

                # Find policies that are fully compliant
                $evaluations = @()
                foreach ($p in $policies) { $evaluations += Evaluate-Policy -policy $p }

                $compliant = $evaluations | Where-Object { $_.Compliant }
                if ($compliant.Count -gt 0) {
                    $names = ($compliant | ForEach-Object { $_.Policy.Name }) -join ' | '
                    return "PASS (Compliant anti-phish policy found: $names)"
                }

                # Prefer the Default policy for reporting if present
                $defaultPolicy = $policies | Where-Object { ($_.Name -ieq 'Office365 AntiPhish Default') -or ($_.Name -match '(?i)\bdefault\b') } | Select-Object -First 1
                if (-not $defaultPolicy) {
                    # Fallback: choose highest precedence if Priority property exists
                    if ($policies | Where-Object { $_.PSObject.Properties.Name -contains 'Priority' }) {
                        $defaultPolicy = $policies | Sort-Object -Property {[int]($_.Priority)} | Select-Object -First 1
                    } else {
                        $defaultPolicy = $policies | Select-Object -First 1
                    }
                }

                $selectedEval = $evaluations | Where-Object { $_.Policy -eq $defaultPolicy } | Select-Object -First 1

                # Build issue summary
                $allIssues = @()
                if ($selectedEval) {
                    $allIssues = $selectedEval.Issues
                } else {
                    # No selected evaluation found; aggregate issues from all policies
                    $allIssues = ($evaluations | ForEach-Object { "Policy '$($_.Policy.Name)': $($_.Issues -join '; ')" })
                }

                $auditSteps = @(
                    "1. Connect to Exchange Online: Connect-ExchangeOnline",
                    "2. Run: Get-AntiPhishPolicy | Format-Table -AutoSize Name,Enabled,PhishThresholdLevel,EnableMailboxIntelligenceProtection,EnableMailboxIntelligence,EnableSpoofIntelligence",
                    "3. Verify the 'Office365 AntiPhish Default' policy (or an appropriate custom policy) is Enabled and has PhishThresholdLevel >= 2 and mailbox/spoof intelligence enabled."
                )

                $remediationSteps = @(
                    "Portal: In Microsoft 365 Defender (https://security.microsoft.com) → Email & collaboration → Policies & rules → Threat policies → Anti-phishing → Edit the Office365 AntiPhish Default (Default) policy (or create a custom policy with appropriate scope):",
                    "  - Ensure the policy is Enabled.",
                    "  - Set Phishing email threshold to at least 2 (Aggressive).",
                    "  - Enable 'Enable mailbox intelligence' and 'Enable intelligence for impersonation protection'.",
                    "  - Enable 'Enable spoof intelligence'.",
                    "PowerShell: Connect-ExchangeOnline then run:",
                    "  - Example: New-AntiPhishPolicy -Name 'Office365 AntiPhish Default' (or use Set-AntiPhishPolicy to modify existing policies)."
                )

                $allIssuesText     = $allIssues -join "`n"
                $auditText         = $auditSteps -join "`n"
                $remediationText   = $remediationSteps -join "`n"

                $message = @"
FAIL (No anti-phish policy meets the expected configuration)

Evaluated policy for reporting: '$($defaultPolicy.Name)'. Issues:
$allIssuesText

Audit steps:
$auditText

Remediation steps:
$remediationText
"@

                return $message
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}