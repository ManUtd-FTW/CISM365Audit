# Requires: Microsoft.Graph modules connected by the orchestrator
# Control: 1.1.3 Ensure that between two and four global admins are designated (L1)

function Get-CISM365Control_1_1_3 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.3'
        Name        = 'Ensure that between two and four Global Administrators are designated'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'Limit the number of Global Administrators to reduce risk.'
        Rationale   = 'Too many global admins increase the attack surface and the blast radius of compromised credentials.'
        References  = @(
            # Microsoft Entra built-in roles overview
            'https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference'
        )
        Audit       = {
            try {
                # Built-in role template ID for Global Administrator
                $gaTemplateId = '62e90394-69f5-4237-9190-012177145e10'

                # Find the activated directory role instance for Global Admin
                $role = Get-MgDirectoryRole -All |
                        Where-Object { $_.RoleTemplateId -eq $gaTemplateId }

                if (-not $role) {
                    # The GA role can be "not activated" in very rare cases; mark as MANUAL per convention
                    return 'MANUAL (Global Administrator directory role is not activated in this tenant)'
                }

                # Enumerate members and count only user principals
                $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All
                $userIds = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

                foreach ($m in $members) {
                    # For Graph PowerShell, type is in AdditionalProperties.'@odata.type'
                    $odataType = $m.AdditionalProperties.'@odata.type'
                    if ($odataType -eq '#microsoft.graph.user') {
                        # Prefer stable ID, fall back to object properties if needed
                        $id = $m.Id
                        if ([string]::IsNullOrWhiteSpace($id) -and $m.AdditionalProperties.objectId) {
                            $id = $m.AdditionalProperties.objectId
                        }
                        if ($id) { [void]$userIds.Add($id) }
                    }
                }

                $count = $userIds.Count

                if ($count -ge 2 -and $count -le 4) {
                    "PASS ($count global admins)"
                } else {
                    "FAIL ($count global admins)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}
