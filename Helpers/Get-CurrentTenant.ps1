function Get-CurrentTenant {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        $Session = $null,

        [Parameter(Mandatory=$false)]
        [int]$VerboseLevel = 0
    )

    try {
        # 1) Inspect a provided session-like object (if any)
        if ($Session -ne $null) {
            if ($Session.PSObject.Properties.Name -contains 'TenantId') {
                $t = $Session.TenantId
                if ($t) { return $t }
            }
            if ($Session.PSObject.Properties.Name -contains 'Tenant') {
                $t = $Session.Tenant
                if ($t) { return $t }
            }
            if ($Session.PSObject.Properties.Name -contains 'Account') {
                $acct = $Session.Account
                if ($acct -and $acct.Id -and ($acct.Id -match '@')) {
                    return ($acct.Id.Split('@')[-1])
                }
            }
        }

        # 2) Try Graph 'me' UPN domain
        if (Get-Command -Name Get-MgUser -ErrorAction SilentlyContinue) {
            $me = Get-MgUser -UserId 'me' -Property userPrincipalName -ErrorAction SilentlyContinue
            if ($me -and $me.UserPrincipalName) {
                $upn = $me.UserPrincipalName
                if ($upn -match '@') { return ($upn.Split('@')[-1]) }
                return $upn
            }
        }

        # 3) Try organization verified domains via Graph
        if (Get-Command -Name Get-MgOrganization -ErrorAction SilentlyContinue) {
            $org = Get-MgOrganization -All -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($org) {
                if ($org.PSObject.Properties.Name -contains 'VerifiedDomains') {
                    $v = $org.VerifiedDomains
                    if ($v -and $v.Count -gt 0) {
                        $def = $v | Where-Object { $_.IsDefault -eq $true } | Select-Object -First 1
                        if ($def -and $def.Name) { return $def.Name }
                        if ($v[0].Name) { return $v[0].Name }
                    }
                }
                if ($org.AdditionalProperties -and $org.AdditionalProperties.ContainsKey('verifiedDomains')) {
                    $v = $org.AdditionalProperties['verifiedDomains']
                    if ($v -and $v.Count -gt 0) {
                        $def = $v | Where-Object { $_.isDefault -eq $true } | Select-Object -First 1
                        if ($def -and $def.name) { return $def.name }
                        if ($v[0].name) { return $v[0].name }
                    }
                }
                if ($org.Id) { return $org.Id }
            }
        }

        return $null
    }
    catch {
        if ($VerboseLevel -gt 0) { Write-Verbose "Get-CurrentTenant error: $($_.Exception.Message)" }
        return $null
    }
}