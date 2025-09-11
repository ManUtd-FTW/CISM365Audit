# Control: 1.1.1 Ensure Administrative accounts are cloud-only (L1)
function Get-CISM365Control_1_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.1'
        Name        = 'Ensure Administrative accounts are cloud-only'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'Administrative accounts should be cloud-only, not synchronized from on-premises.'
        Rationale   = 'Cloud-only admin accounts reduce exposure to on-prem compromise paths and sync-related risks.'
        References  = @(
            'https://www.tenable.com/audits/CIS_Microsoft_365_Foundations_v5.0.0_L1_E3',
            'https://maester.dev/docs/tests/cis/',
            'https://learn.microsoft.com/graph/api/resources/user#properties'
        )
Notes       = 'Testing the notes section to see if this shows up properly.'
        Audit       = {
            try {
                # Lazy-load tenant helper only at audit runtime (safe: no top-level actions)
                try {
                    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
                    $helperPath = Join-Path $scriptDir 'Helper-GetTenant.ps1'
                    if (Test-Path $helperPath) {
                        # swallow helper load errors so the audit still runs
                        try { . $helperPath } catch {}
                    }
                } catch {}

                # Collect all activated directory roles (use -ErrorAction SilentlyContinue so audit returns rather than throws)
                $roles = Get-MgDirectoryRole -All -ErrorAction SilentlyContinue
                if (-not $roles -or $roles.Count -eq 0) { return 'MANUAL (No activated directory roles found)' }

                # Collect unique user members across all roles
                $userIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
                foreach ($role in $roles) {
                    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All -ErrorAction SilentlyContinue
                    foreach ($m in $members) {
                        $odataType = $null
                        if ($m.AdditionalProperties -and $m.AdditionalProperties.ContainsKey('@odata.type')) {
                            $odataType = $m.AdditionalProperties['@odata.type']
                        } elseif ($m.PSObject.Properties.Name -contains '@odata.type') {
                            $odataType = $m.'@odata.type'
                        }

                        if ($odataType -eq '#microsoft.graph.user') {
                            $id = $m.Id
                            if ([string]::IsNullOrWhiteSpace($id) -and $m.AdditionalProperties -and $m.AdditionalProperties.ContainsKey('objectId')) {
                                $id = $m.AdditionalProperties['objectId']
                            }
                            if ($id) { [void]$userIds.Add($id) }
                        }
                    }
                }

                if ($userIds.Count -eq 0) {
                    return 'MANUAL (No administrative user assignments are currently active)'
                }

                # Evaluate each admin user for on-prem sync
                $violations = New-Object System.Collections.Generic.List[object]
                foreach ($uid in $userIds) {
                    $u = Get-MgUser -UserId $uid -Property 'id,displayName,userPrincipalName,onPremisesSyncEnabled' -ErrorAction SilentlyContinue
                    # Cloud-only => onPremisesSyncEnabled -eq $null
                    if ($null -ne $u -and $null -ne $u.OnPremisesSyncEnabled) {
                        $violations.Add([PSCustomObject]@{
                            DisplayName       = $u.DisplayName
                            UserPrincipalName = $u.UserPrincipalName
                            OnPremisesSyncEnabled = $u.OnPremisesSyncEnabled
                        })
                    }
                }

                if ($violations.Count -eq 0) {
                    return "PASS (All $($userIds.Count) administrative accounts are cloud-only)"
                } else {
                    $sample = ($violations | Select-Object -First 5 | ForEach-Object { $_.UserPrincipalName }) -join ', '
                    return "FAIL ($($violations.Count) administrative account(s) not cloud-only)"
                }
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}