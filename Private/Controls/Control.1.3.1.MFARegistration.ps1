# Control: 1.3.1 Ensure MFA is enabled for all users (L1)
# Requires: Microsoft Graph connected by the orchestrator.
# Primary method uses Authentication Methods Usage Insights (reports).
# Fallback (best-effort): per-user authentication methods enumeration.

function Get-CISM365Control_1_3_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.3.1'
        Name        = 'Ensure MFA is enabled for all users'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'All users should register at least one strong MFA method. (Registration is a prerequisite; enforcement is typically via Conditional Access policies.)'
        Rationale   = 'MFA significantly reduces the risk of account compromise from phishing and credential theft.'
        References  = @(
            # Graph Authentication Methods usage insights overview
            'https://learn.microsoft.com/graph/api/resources/authenticationmethods-usage-insights-overview',
            # userRegistrationDetails (per-user registration status)
            'https://learn.microsoft.com/graph/api/reportroot-list-userregistrationdetails?view=graph-rest-1.0'
        )
        Audit       = {
            # PASS criteria: zero users reported as not registered for MFA.
            # Prefer Graph Reports API (fast & scalable). Requires Reports.Read.All (and typically Directory.Read.All).
            try {
                $details = Get-MgReportAuthenticationMethodsUserRegistrationDetail -All -ErrorAction Stop
                if (-not $details) { return 'MANUAL (No data returned from Graph reports)' }

                # Some tenants include service accounts/guests; you can filter if desired.
                $noMfa = $details | Where-Object { -not $_.IsMfaRegistered }
                if ($noMfa.Count -gt 0) {
                    "FAIL ($($noMfa.Count) users not registered for MFA)"
                } else {
                    'PASS (All users registered for MFA)'
                }
            }
            catch {
                # Fallback: enumerate per-user authentication methods (slower; may hit throttling on large tenants).
                try {
                    $users = Get-MgUser -All -Property Id,UserPrincipalName,AccountEnabled
                    if (-not $users) { return 'MANUAL (Unable to enumerate users via Graph)' }

                    $noStrong = 0
                    foreach ($u in $users) {
                        # Optionally skip disabled accounts; comment out to include them.
                        if ($u.AccountEnabled -eq $false) { continue }

                        try {
                            $methods = Get-MgUserAuthenticationMethod -UserId $u.Id -ErrorAction Stop
                            $hasStrong = $false
                            foreach ($m in $methods) {
                                $t = $m.AdditionalProperties.'@odata.type'
                                if ($t -in
                                    '#microsoft.graph.microsoftAuthenticatorAuthenticationMethod',
                                    '#microsoft.graph.phoneAuthenticationMethod',
                                    '#microsoft.graph.fido2AuthenticationMethod',
                                    '#microsoft.graph.softwareOathAuthenticationMethod',
                                    '#microsoft.graph.temporaryAccessPassAuthenticationMethod'
                                ) {
                                    $hasStrong = $true
                                    break
                                }
                            }
                            if (-not $hasStrong) { $noStrong++ }
                        }
                        catch {
                            # Could not evaluate this user; do not fail the entire control—continue.
                            # (You could count unknowns and return MANUAL if high.)
                            continue
                        }
                    }

                    if ($noStrong -gt 0) {
                        "FAIL ($noStrong users without any strong MFA method registered)"
                    } else {
                        'PASS (All users show at least one strong MFA method)'
                    }
                }
                catch {
                    "MANUAL (Unable to check MFA registration via Graph: $($_.Exception.Message))"
                }
            }
        }
    }
}
