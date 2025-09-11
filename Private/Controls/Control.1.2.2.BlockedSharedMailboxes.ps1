function Get-CISM365Control_1_2_2 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.2.2'
        Name        = 'Ensure sign-in to shared mailboxes is blocked'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('ExchangeOnline','Graph')
        Description = 'Shared mailboxes must have the associated user account sign-in blocked; access should be via delegation only.'
        Rationale   = 'Blocking direct sign-in prevents credential abuse and ensures actions are attributable to individual users via delegated access.'
        References  = @(
            'https://www.tenable.com/audits/items/CIS_Microsoft_365_Foundations_v5.0.0_L1_E3.audit:bf9c158531d41d00ed8a8d7bafa37ead',
            'https://learn.microsoft.com/microsoft-365/lighthouse/m365-lighthouse-block-signin-shared-mailboxes?view=o365-worldwide',
            'https://learn.microsoft.com/powershell/module/exchangepowershell/get-exomailbox?view=exchange-ps',
            'https://practical365.com/move-your-exchange-online-scripts-to-use-get-exomailbox/',
            'https://maester.dev/docs/tests/cis/'
        )
        Audit = {
            try {
                # Defensive pre-checks for required cmdlets / contexts
                if (-not (Get-Command -Name Get-EXOMailbox -ErrorAction SilentlyContinue)) {
                    return "MANUAL (Get-EXOMailbox not available in this session. Install/enable ExchangeOnlineManagement and/or pre-authenticate with Connect-ExchangeOnline.)"
                }
                if (-not (Get-Command -Name Get-MgUser -ErrorAction SilentlyContinue)) {
                    return "MANUAL (Get-MgUser not available in this session. Install/enable Microsoft.Graph and/or pre-authenticate with Connect-MgGraph.)"
                }
                if (Get-Command -Name Get-MgContext -ErrorAction SilentlyContinue) {
                    $mgCtx = Get-MgContext -ErrorAction SilentlyContinue
                    if (-not $mgCtx) {
                        return "MANUAL (No Microsoft Graph context is active. Run Connect-MgGraph interactively or pre-authenticate and re-run.)"
                    }
                }

                # Get shared mailboxes (strict error handling)
                $sharedMailboxes = Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited -ErrorAction Stop

                if (-not $sharedMailboxes -or ($sharedMailboxes -is [System.Collections.ICollection] -and $sharedMailboxes.Count -eq 0)) {
                    return 'PASS (No shared mailboxes found)'
                }

                $nonCompliant = New-Object System.Collections.Generic.List[object]
                $checked = 0

                foreach ($mbx in $sharedMailboxes) {
                    $checked++

                    $oid = $mbx.ExternalDirectoryObjectId
                    if ([string]::IsNullOrWhiteSpace($oid)) {
                        $nonCompliant.Add([PSCustomObject]@{
                            Mailbox        = ($mbx.PrimarySmtpAddress -as [string])
                            UserPrincipal  = $null
                            AccountEnabled = $null
                            Reason         = 'Missing ExternalDirectoryObjectId'
                        })
                        continue
                    }

                    try {
                        # Suppress module Warning/Verbose streams so transient module messages (404 traces) don't clutter output.
                        # Use -ErrorAction Stop so not-found becomes catchable here.
                        $user = Get-MgUser -UserId $oid -ErrorAction Stop 3>$null 4>$null
                        if ($null -eq $user) {
                            $nonCompliant.Add([PSCustomObject]@{
                                Mailbox        = ($mbx.PrimarySmtpAddress -as [string])
                                UserPrincipal  = $null
                                AccountEnabled = $null
                                Reason         = 'User not found in Graph'
                            })
                            continue
                        }

                        # Compliant when sign-in is blocked => AccountEnabled equals $false
                        if ($user.AccountEnabled -ne $false) {
                            $nonCompliant.Add([PSCustomObject]@{
                                Mailbox        = ($mbx.PrimarySmtpAddress -as [string])
                                UserPrincipal  = ($user.UserPrincipalName -as [string])
                                AccountEnabled = ($user.AccountEnabled -as [string])
                                Reason         = 'Sign-in not blocked'
                            })
                        }
                    }
                    catch {
                        # Capture the error message and treat as unresolved / non-compliant so reviewer can investigate.
                        $errMsg = $_.Exception.Message
                        # For common 404 ResourceNotFound, give a clearer reason
                        if ($errMsg -match 'Request_ResourceNotFound' -or $errMsg -match 'does not exist') {
                            $reason = 'User object not found in tenant (404)'
                        } else {
                            $reason = "Lookup error: $errMsg"
                        }

                        $nonCompliant.Add([PSCustomObject]@{
                            Mailbox        = ($mbx.PrimarySmtpAddress -as [string])
                            UserPrincipal  = $null
                            AccountEnabled = $null
                            Reason         = $reason
                        })
                    }
                }

                if ($nonCompliant.Count -eq 0) {
                    return "PASS (All $checked shared mailbox accounts have sign-in blocked)"
                }
                else {
                    $sample = ($nonCompliant | Select-Object -First 5 | ForEach-Object {
                        if ($_.UserPrincipal) { $_.UserPrincipal } else { $_.Mailbox }
                    }) -join ', '
                    return "FAIL ($($nonCompliant.Count) shared mailbox account(s) with sign-in enabled or unresolved; examples: $sample)"
                }
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}