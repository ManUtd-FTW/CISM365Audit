function Get-CISM365Control_2_1_13 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '2.1.13'
        Name        = "Ensure all security threats in the Threat protection status report are reviewed at least weekly"
        Profile     = 'L1'
        Automated   = $false
        Services    = @('Defender')
        Description = @'
The Threat protection status report displays instances of blocked malware, phishing, impersonation, and other threats. The report should be reviewed weekly to monitor threat activity and consider further mitigation steps.
'@
        Rationale   = @'
Regular review of the Threat protection status report provides insight into the volume and types of security threats targeting users, helping inform decisions on threat mitigations.
'@
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365security/reports-email-security?view=o365-worldwide'
        )
        Audit = {
            try {
                $steps = @(
                    "1. Ensure procedures are in place and followed to review the Threat protection status report at least weekly.",
                    "",
                    "To manually review the report:",
                    "  • Navigate to Microsoft 365 Defender: https://security.microsoft.com",
                    "  • Click Email & collaboration > Review.",
                    "  • Select Malware trends.",
                    "  • On the Threat Explorer page, select 'All email' and review statistics."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Verify the Threat protection status report is reviewed weekly to monitor security threats.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}