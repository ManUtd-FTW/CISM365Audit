function Get-CISM365Control_1_3_4 {
    [OutputType([hashtable])]
    param()

    return @{
        Id        = '1.3.4'
        Name      = "Ensure 'User owned apps and services' is restricted"
        Profile   = 'L1'
        Automated = $false
        Services  = @('AdminCenter')
        Description = 'Disable users ability to install Office Store add-ins and prevent starting 365 trials on behalf of the organization.'
        Rationale  = 'Preventing self-installed add-ins and trials reduces the risk of data exposure via unvetted third-party apps.'
        References = @(
            'https://admin.microsoft.com (Microsoft 365 admin center – Settings → Org settings → User owned apps and services)',
            'CIS Microsoft 365 Foundations Benchmark'
        )
        Audit = {
            # Manual instructions only — no helper calls
            "MANUAL: Verify in the Microsoft 365 admin center that 'Let users access the Office Store' and 'Let users start trials on behalf of your organization' are NOT checked.`n" +
            "Audit steps:`n1. Sign in to https://admin.microsoft.com`n2. Settings → Org settings → Services → 'User owned apps and services'`n3. Confirm the two options are unchecked."
        }
    }
}