# Control: 5.1.8.1 (L1) Ensure that password hash sync is enabled for hybrid deployments
function Get-CISM365Control_5_1_8_1 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '5.1.8.1'
        Name        = 'Ensure that password hash sync is enabled for hybrid deployments'
        Profile     = 'L1'
        Automated   = $true
        Services    = @('Graph', 'AzureAD')
        Description = "Password hash synchronization is a hybrid identity method for Azure AD Connect. It synchronizes a hash, of the hash, of a user's on-premises AD password to Azure AD, enabling single sign-on and leaked credential detection. Applies only to tenants operating in hybrid mode with Azure AD Connect."
        Rationale   = "Password hash sync reduces password fatigue, enables Microsoft leaked credential detection, and allows Azure AD sign-ins even if the on-premises environment is unavailable."
        References  = @(
            'https://learn.microsoft.com/en-us/azure/active-directory/hybrid/whatis-phs',
            'https://learn.microsoft.com/en-us/azure/active-directory/identityprotection/concept-identity-protection-risks#user-linked-detections',
            'https://www.microsoft.com/en-us/download/details.aspx?id=47594'
        )
        Audit       = {
            try {
                # Check if the tenant is operating in hybrid mode (OnPremisesSyncEnabled)
                $org = Get-MgOrganization -Property "Id,OnPremisesSyncEnabled" -ErrorAction Stop
                if (-not $org) {
                    return "MANUAL (No organization detected. Unable to determine hybrid status.)"
                }
                if (-not $org.OnPremisesSyncEnabled) {
                    return "PASS (Tenant is not hybrid. Password hash sync not required.)"
                }

                # Check Azure AD Connect sync status if available
                try {
                    $syncStatus = Get-ADSyncScheduler -ErrorAction Stop
                    if ($syncStatus.PasswordHashSyncEnabled) {
                        return "PASS (Password hash sync is enabled for hybrid deployment.)"
                    } else {
                        return "FAIL (Password hash sync is NOT enabled for hybrid deployment.)"
                    }
                } catch {
                    return "MANUAL (Unable to check Azure AD Connect password hash sync. Please verify in Azure AD Connect tool or Entra Admin Center.)"
                }
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}