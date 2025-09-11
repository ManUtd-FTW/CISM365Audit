function Get-CISM365Control_1_3_2 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '1.3.2'
        Name        = "Ensure 'Idle session timeout' is set to '3 hours (or less)' for unmanaged devices"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('AdminCenter','EntraID')
        Description = @'
Idle session timeout allows configuration of a setting that signs out inactive users after a set amount of time from all Microsoft 365 web apps. Combined with Conditional Access, this limits impact to unmanaged devices only.
'@
        Rationale   = @'
Automatically ending idle sessions helps protect sensitive data and prevents unauthorized access on unattended, unmanaged devices.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/admin/manage/idle-sessiontimeout-web-apps?view=o365-worldwide'
        )
        Audit = {
            try {
                $steps = @(
                    "Step 1 - Ensure Idle session timeout is configured:",
                    "  1. Sign in to Microsoft 365 admin center: https://admin.microsoft.com/",
                    "  2. Expand Settings > Org settings.",
                    "  3. Click Security & Privacy tab.",
                    "  4. Select Idle session timeout.",
                    "  5. Verify 'Turn on' is checked and the inactivity period is set to 3 hours (or less).",
                    "",
                    "Step 2 - Ensure the Conditional Access policy is in place:",
                    "  1. Sign in to Microsoft Entra admin center: https://entra.microsoft.com/",
                    "  2. Expand Azure Active Directory > Protect & secure > Conditional Access.",
                    "  3. Inspect policies for one meeting ALL conditions:",
                    "     • Users: All users",
                    "     • Cloud apps: Office 365",
                    "     • Conditions > Client apps: Browser ONLY",
                    "     • Session: Use app enforced restrictions",
                    "     • Enable Policy: On"
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify Idle session timeout is set to 3 hours (or less) for unmanaged devices and a Conditional Access policy enforces this.`nAudit steps:`n$joined`nDefault: Not configured. (Idle sessions will not timeout.)"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}