function Get-CISM365Control_2_1_6 {
    [OutputType([hashtable])]
    param()

    return @{
        Id        = '2.1.6'
        Name      = 'Ensure Exchange Online Spam Policies are set to notify administrators'
        Profile   = 'L1'
        Automated = $true
        Services  = @('ExchangeOnline')
        Description = @'
Configure Exchange Online outbound spam policies so that administrators receive notifications and a copy of suspicious outbound messages when a sender in the organization is blocked for sending spam.
'@
        Rationale = 'A blocked account often indicates compromise; notifying administrators and preserving evidence helps detection and response.'
        References = @(
            'https://learn.microsoft.com/microsoft-365/security/office-365-security/anti-spam-protection',
            'https://learn.microsoft.com/powershell/module/exchange/get-hostedoutboundspamfilterpolicy'
        )
        Audit = {
            try {
                # Require the Exchange cmdlet
                if (-not (Get-Command -Name Get-HostedOutboundSpamFilterPolicy -ErrorAction SilentlyContinue)) {
                    return "MANUAL (Get-HostedOutboundSpamFilterPolicy is not available in this session. Install/enable the ExchangeOnlineManagement module and Connect-ExchangeOnline and re-run.)"
                }

                $policies = Get-HostedOutboundSpamFilterPolicy -ErrorAction Stop

                if (-not $policies -or $policies.Count -eq 0) {
                    return "MANUAL (No hosted outbound spam filter policies returned; verify Exchange Online connectivity and permissions.)"
                }

                # Prefer the Default policy when present, otherwise pick highest-priority if Priority exists, otherwise take the first.
                $selected = $policies | Where-Object { ($_.Name -eq 'Default') -or ($_.Identity -match 'Default') } | Select-Object -First 1
                if (-not $selected) {
                    if ($policies | Where-Object { $_.PSObject.Properties.Name -contains 'Priority' }) {
                        # choose the numeric lowest Priority value (highest precedence)
                        $selected = $policies | Sort-Object -Property {[int]($_.Priority)} | Select-Object -First 1
                    } else {
                        $selected = $policies | Select-Object -First 1
                    }
                }

                if (-not $selected) {
                    return "MANUAL (Unable to determine which outbound spam policy to evaluate. Inspect policies in the Defender portal or via Get-HostedOutboundSpamFilterPolicy.)"
                }

                # Ensure expected properties exist
                $expectedProps = @('BccSuspiciousOutboundMail','NotifyOutboundSpam','BccSuspiciousOutboundAdditionalRecipients','NotifyOutboundSpamRecipients')
                $missing = @()
                foreach ($p in $expectedProps) {
                    if (-not ($selected.PSObject.Properties.Name -contains $p)) { $missing += $p }
                }
                if ($missing.Count -gt 0) {
                    return "MANUAL (Selected policy is missing expected properties: $($missing -join ', '). Verify configuration in the Defender portal.)"
                }

                # Read and normalize values
                $bccEnabled    = [bool]$selected.BccSuspiciousOutboundMail
                $notifyEnabled = [bool]$selected.NotifyOutboundSpam

                # Recipients may be collection or string; normalize to array
                $bccRecipients = @()
                if ($selected.BccSuspiciousOutboundAdditionalRecipients) {
                    if ($selected.BccSuspiciousOutboundAdditionalRecipients -is [System.Array]) {
                        $bccRecipients = $selected.BccSuspiciousOutboundAdditionalRecipients
                    } else {
                        $bccRecipients = @($selected.BccSuspiciousOutboundAdditionalRecipients)
                    }
                }

                $notifyRecipients = @()
                if ($selected.NotifyOutboundSpamRecipients) {
                    if ($selected.NotifyOutboundSpamRecipients -is [System.Array]) {
                        $notifyRecipients = $selected.NotifyOutboundSpamRecipients
                    } else {
                        $notifyRecipients = @($selected.NotifyOutboundSpamRecipients)
                    }
                }

                # Evaluate compliance: both toggles True and recipients present
                $issues = @()
                if (-not $bccEnabled)    { $issues += "BccSuspiciousOutboundMail = $bccEnabled (expected True)" }
                if (-not $notifyEnabled) { $issues += "NotifyOutboundSpam = $notifyEnabled (expected True)" }
                if ($bccRecipients.Count -eq 0)    { $issues += "BccSuspiciousOutboundAdditionalRecipients is empty (expected at least one address)" }
                if ($notifyRecipients.Count -eq 0) { $issues += "NotifyOutboundSpamRecipients is empty (expected at least one address)" }

                if ($issues.Count -eq 0) {
                    return "PASS (Policy '$($selected.Name)': BccSuspiciousOutboundMail=True; NotifyOutboundSpam=True; BccRecipients=$($bccRecipients -join ', '); NotifyRecipients=$($notifyRecipients -join ', '))"
                }

                # Build audit and remediation guidance
                $auditSteps = @(
                    "1. Connect to Exchange Online: Connect-ExchangeOnline",
                    "2. Run: Get-HostedOutboundSpamFilterPolicy | Select-Object Name,BccSuspiciousOutboundMail,NotifyOutboundSpam,BccSuspiciousOutboundAdditionalRecipients,NotifyOutboundSpamRecipients",
                    ("3. If multiple policies exist, inspect the highest priority (or the 'Default' policy). The check evaluated policy: '{0}'" -f $selected.Name)
                )

                $remediationSteps = @(
                    "Portal: In Microsoft 365 Defender (https://security.microsoft.com) → Email & collaboration → Policies & rules → Anti-spam → Outbound policy (Default or custom with highest priority):",
                    "  - Enable 'Send a copy of outbound messages that exceed these limits to these users and groups' and add desired Bcc recipients.",
                    "  - Enable 'Notify these users and groups if a sender is blocked due to sending outbound spam' and add desired notify recipients.",
                    "PowerShell: Connect-ExchangeOnline then run:",
                    "  - Set-HostedOutboundSpamFilterPolicy -Identity Default -BccSuspiciousOutboundMail $true -BccSuspiciousOutboundAdditionalRecipients @('<insert-email>')",
                    "  - Set-HostedOutboundSpamFilterPolicy -Identity Default -NotifyOutboundSpam $true -NotifyOutboundSpamRecipients @('<insert-email>')",
                    "  - For custom policies, set the same properties on the appropriate policy identity."
                )

                $issueText = $issues -join '; '
                $auditText = $auditSteps -join "`n"
                $remediationText = $remediationSteps -join "`n"

                $message = @"
FAIL ($issueText)

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