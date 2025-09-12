function Get-CISM365Control_1_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.1.1'
        Name        = "Ensure Administrative accounts are separate and cloud-only"
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph')
        Description = 'Administrative accounts should be cloud-only and not have unnecessary application licenses. (Use Entra ID P1/P2 when possible.)'
        Rationale   = 'Separating admin accounts and keeping them cloud-only reduces the attack surface and prevents cross-environment compromise.'
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/roles/best-practices#9-use-cloud-native-accounts-for-azure-ad-roles'
        )
        Audit       = {
            try {
                $admins = Get-MgUser -All -Property UserPrincipalName,OnPremisesSyncEnabled,AssignedLicenses
                if (-not $admins) { return 'MANUAL (No admin accounts found via Graph)' }

                $failures = @()
                foreach ($admin in $admins) {
                    if ($admin.Id) {
                        $roles = Get-MgUserMemberOf -UserId $admin.Id | Where-Object { $_.AdditionalProperties['@odata.type'] -like '*directoryRole' }
                        if ($roles) {
                            $cloudOnly = -not $admin.OnPremisesSyncEnabled
                            $licenseNames = $admin.AssignedLicenses | ForEach-Object { $_.SkuId }
                            $licenseType = if ($licenseNames -match "ENTERPRISEPREMIUM|ENTERPRISEPREMIUM_NOPSTNCONF") { "Entra ID P1/P2" } else { "Other" }
                            if (-not $cloudOnly -or $licenseType -ne "Entra ID P1/P2") {
                                $failures += $admin.UserPrincipalName
                            }
                        }
                    } else {
                        Write-Verbose "Skipping user $($admin.UserPrincipalName) with empty Id."
                    }
                }
                if ($failures.Count -gt 0) {
                    "FAIL (The following admin accounts are not cloud-only and/or not using Entra ID P1/P2: $($failures -join ', '))"
                } else {
                    'PASS (All admin accounts are cloud-only and using recommended license types)'
                }
            }
            catch {
                "MANUAL (Unable to enumerate admin accounts via Graph: $($_.Exception.Message))"
            }
        }
    }
}