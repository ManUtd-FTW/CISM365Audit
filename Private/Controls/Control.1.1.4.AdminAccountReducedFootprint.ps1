# Control: 1.1.4 Ensure administrative accounts use licenses with a reduced application footprint (L1)
function Get-CISM365Control_1_1_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.4'
        Name        = 'Ensure administrative accounts use licenses with a reduced application footprint'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'Privileged users should have no licenses or only Entra ID P1/P2 to avoid access to application workloads.'
        Rationale   = 'Limiting app-enabled licenses for admins reduces exposure to phishing, malware, and risky content across collaborative apps.'
        References  = @(
            'https://www.tenable.com/audits/items/CIS_Microsoft_365_Foundations_v5.0.0_L1_E3.audit:ec4446e690286b01c1ac263bd0266cc9',
            'https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference'
        )
        Audit       = {
            try {
                # Activated directory roles
                $roles = Get-MgDirectoryRole -All
                if (-not $roles) { return 'MANUAL (No activated directory roles found)' }

                # Unique admin user members
                $userIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
                foreach ($role in $roles) {
                    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All
                    foreach ($m in $members) {
                        $odataType = $m.AdditionalProperties['@odata.type']
                        if ($odataType -eq '#microsoft.graph.user') {
                            $id = $m.Id
                            if ([string]::IsNullOrWhiteSpace($id) -and $m.AdditionalProperties.objectId) {
                                $id = $m.AdditionalProperties.objectId
                            }
                            if ($id) { [void]$userIds.Add($id) }
                        }
                    }
                }

                if ($userIds.Count -eq 0) {
                    return 'MANUAL (No administrative user assignments are currently active)'
                }

                # Allowed license SKU part numbers per CIS guidance: AAD P1/P2 only
                $allowed = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
                [void]$allowed.Add('AAD_PREMIUM')     # Entra ID P1
                [void]$allowed.Add('AAD_PREMIUM_P2')  # Entra ID P2

                $violations = New-Object System.Collections.Generic.List[object]

                foreach ($uid in $userIds) {
                    $u = Get-MgUser -UserId $uid -Property 'id,displayName,userPrincipalName'
                    $lics = @( Get-MgUserLicenseDetail -UserId $uid -All -ErrorAction SilentlyContinue )
                    if ($lics.Count -eq 0) {
                        continue # Unlicensed => compliant
                    }

                    # Gather SKU part numbers for evaluation
                    $skuParts = @($lics | ForEach-Object { $_.SkuPartNumber }) | Where-Object { $_ }
                    # If any license is *not* in the allowed set, this admin is non-compliant
                    $nonAllowed = $skuParts | Where-Object { -not $allowed.Contains($_) }
                    if ($nonAllowed.Count -gt 0) {
                        $violations.Add([PSCustomObject]@{
                            DisplayName       = $u.DisplayName
                            UserPrincipalName = $u.UserPrincipalName
                            Licenses          = ($skuParts -join ';')
                        })
                    }
                }

                if ($violations.Count -eq 0) {
                    "PASS (All $($userIds.Count) administrative accounts are unlicensed or only AAD P1/P2)"
                } else {
                    $sample = ($violations | Select-Object -First 5 | ForEach-Object { "$($_.UserPrincipalName) [$($_.Licenses)]" }) -join ', '
                    "FAIL ($($violations.Count) administrative account(s) with non-allowed licenses; examples: $sample)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}
