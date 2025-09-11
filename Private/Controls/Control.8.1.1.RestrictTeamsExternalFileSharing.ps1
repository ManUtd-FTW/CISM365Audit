function Get-CISM365Control_8_1_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '8.1.1'
        Name        = 'Ensure external file sharing in Teams is enabled for only approved cloud storage services'
        Profile     = 'L2'
        Automated   = $true
        Services    = @('Teams')
        Description = @'
Microsoft Teams enables file sharing via SharePoint Online and optionally third-party cloud services. Only authorized cloud storage providers should be enabled.
'@
        Rationale   = @'
Restricting file sharing to approved cloud storage providers reduces risk of data leakage and unauthorized access.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/enterprise/manage-skype-for-business-online-with-microsoft-365-powershell?view=o365-worldwide'
        )
        Audit = {
            try {
                $config = Get-CsTeamsClientConfiguration
                $approvedProviders = @('AllowSharePoint', 'AllowOneDriveBusiness') # You may need to adjust this based on policy
                $externalProviders = @('AllowDropbox','AllowBox','AllowGoogleDrive','AllowShareFile','AllowEgnyte')
                $failProviders = @()
                foreach ($prov in $externalProviders) {
                    if ($config.$prov) {
                        $failProviders += $prov
                    }
                }
                if ($failProviders.Count -eq 0) {
                    "PASS (No unauthorized cloud storage providers allowed)"
                } else {
                    "FAIL (These providers should be disabled: $($failProviders -join ', '))"
                }
            }
            catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}