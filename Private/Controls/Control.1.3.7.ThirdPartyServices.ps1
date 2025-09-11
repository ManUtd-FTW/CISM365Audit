function Get-CISM365Control_1_3_7 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.7'
        Name        = "Ensure 'third-party storage services' are restricted in 'Microsoft 365 on the web'"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AdminCenter')
        Description = 'Ensure Microsoft 365 on the web third-party storage services are restricted so users cannot open files stored in third‑party storage providers.'
        Rationale   = 'Third-party storage services may increase the risk of data breaches or unauthorized access because they may not adhere to the same security standards as the organization.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/admin/setup/set-up-file-storageand-sharing?view=o365-worldwide#enable-or-disable-third-party-storageservices'
        )
        Audit = {
            try {
                $auditSteps = @(
                    "1. Navigate to Microsoft 365 admin center: https://admin.microsoft.com",
                    "2. In the left navigation, go to Settings → Org settings → Services → Microsoft 365 on the web",
                    "3. Ensure 'Let users open files stored in third-party storage services in Microsoft 365 on the web' is NOT checked."
                )

                $remediationSteps = @(
                    "1. Navigate to Microsoft 365 admin center: https://admin.microsoft.com",
                    "2. Go to Settings → Org settings → Services → Microsoft 365 on the web",
                    "3. Uncheck 'Let users open files stored in third-party storage services in Microsoft 365 on the web' and save changes."
                )

                $auditJoined = $auditSteps -join "`n"
                $remediationJoined = $remediationSteps -join "`n"

                $message  = "MANUAL: Verify Microsoft 365 on the web third-party storage services are restricted.`n"
                $message += "Audit steps:`n$auditJoined`n`n"
                $message += "Remediation steps:`n$remediationJoined`n`n"
                $message += "Default: Enabled - Users are able to open files stored in third-party storage services.`n"
                $message += "Impact: Changing this setting may prevent users who rely on external storage providers from opening files via Microsoft 365 on the web."

                return $message
            } catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}