function Get-CISM365Control_5_2_3_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id = '5.2.3.2'
        Name = 'Ensure custom banned password lists are used'
        Profile = 'L1'
        Automated = $true
        Services = @('AzureAD')
        Description = @'
Ensure that a custom banned password list is configured in Azure AD Password Protection to prevent users from choosing weak or easily guessable passwords.
'@
        Rationale = @'
Custom banned password lists enhance security by preventing users from selecting passwords that are commonly used, easily guessed, or specific to the organization (e.g., company name, product names).
'@
        References = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-password-ban-bad',
            'https://learn.microsoft.com/en-us/azure/active-directory/authentication/howto-password-ban-bad'
        )
        Audit = {
            try {
                $config = Get-AzureADPasswordProtectionPolicy

                if (-not $config) {
                    "FAIL (Unable to retrieve Azure AD Password Protection policy)"
                    return
                }

                $customListEnabled = $config.CustomBannedPasswords -ne $null -and $config.CustomBannedPasswords.Count -gt 0

                if ($customListEnabled) {
                    "PASS (Custom banned password list is configured with $($config.CustomBannedPasswords.Count) entries)"
                } else {
                    "FAIL (Custom banned password list is not configured or is empty)"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}
