function Get-CISM365Control_2_1_4 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '2.1.4'
        Name        = "Ensure Safe Attachments policy is enabled"
        Profile     = 'L2'
        Automated   = $true
        Services    = @('ExchangeOnline')
        Description = "Safe Attachments policy should be enabled for all users, with detection response set to Block and Quarantine Policy set to AdminOnlyAccessPolicy."
        Rationale   = "Scans attachments for malware before delivery, protecting users from advanced threats."
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-attachments-policies-configure?view=o365-worldwide'
        )
        Audit       = {
            try {
                $policies = Get-SafeAttachmentPolicy | Where-Object { $_.Enable -eq $true }
                $passPolicy = $policies | Where-Object {
                    $_.Action -eq "Block" -and
                    $_.QuarantinePolicy -eq "AdminOnlyAccessPolicy"
                }
                if ($passPolicy) {
                    "PASS (Safe Attachments policy is enabled with required settings)"
                } else {
                    "FAIL (Safe Attachments policy is not enabled or missing required settings)"
                }
            }
            catch {
                "MANUAL (Unable to check Safe Attachments policy: $($_.Exception.Message))"
            }
        }
    }
}