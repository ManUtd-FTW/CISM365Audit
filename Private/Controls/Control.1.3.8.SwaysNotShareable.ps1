function Get-CISM365Control_1_3_8 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.8'
        Name        = "Ensure that Sways cannot be shared with people outside of your organization"
        Profile     = 'L2'
        Automated   = $false
        Services    = @('AdminCenter')
        Description = 'Prevent users from sharing Sway items with people outside the organization via the Microsoft 365 admin center setting.'
        Rationale   = 'Sway content can contain sensitive information; disabling external sharing reduces the risk of accidental data exfiltration to third parties.'
        References  = @(
            'https://support.microsoft.com/en-us/office/administrator-settings-for-sway-d298e79b-b6ab-44c6-9239-aa312f5784d4'
        )
        Audit = {
            try {
                $auditSteps = @(
                    "1. Navigate to Microsoft 365 admin center: https://admin.microsoft.com",
                    "2. Expand Settings and select 'Org settings'",
                    "3. Under Services, choose 'Sway'",
                    "4. Under Sharing, verify 'Let people in your organization share their sways with people outside your organization' is NOT checked."
                )

                $remediationSteps = @(
                    "1. Navigate to Microsoft 365 admin center: https://admin.microsoft.com",
                    "2. Expand Settings and select 'Org settings'",
                    "3. Under Services, choose 'Sway'",
                    "4. Uncheck 'Let people in your organization share their sways with people outside your organization' and Save."
                )

                $auditJoined = $auditSteps -join "`n"
                $remediationJoined = $remediationSteps -join "`n"

                $message  = "MANUAL: Verify Sway external sharing is restricted.`n"
                $message += "Audit steps:`n$auditJoined`n`n"
                $message += "Remediation steps:`n$remediationJoined`n`n"
                $message += "Default: Enabled - By default users can share sways outside the organization.`n"
                $message += "Impact: Disabling external sharing may prevent users who rely on cross-organization collaboration from sharing Sway content externally."

                return $message
            } catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}