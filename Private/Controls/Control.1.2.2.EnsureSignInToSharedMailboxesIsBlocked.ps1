function Get-CISM365Control_1_2_2 {
    [OutputType([hashtable])]
    param()

    @{
        Id          = '1.2.2'
        Name        = "Ensure sign-in to shared mailboxes is blocked"
        Profile     = 'L1'
        Automated   = $false # ExchangeOnlineManagement and AzureAD required for full automation.
        Services    = @('ExchangeOnline', 'AzureAD')
        Description = 'Sign-in should be blocked for shared mailboxes, preventing direct access.'
        Rationale   = 'Prevents use of shared mailboxes for direct sign-in and potential abuse.'
        References  = @(
            'https://learn.microsoft.com/en-us/microsoft-365/admin/email/create-a-shared-mailbox?view=o365-worldwide#block-sign-in-for-the-shared-mailbox-account'
        )
        Audit = {
            try {
                $steps = @(
                    "Step 1: Review shared mailboxes in the UI:",
                    "  1. Navigate to Microsoft 365 admin center: https://admin.microsoft.com/",
                    "  2. Expand Teams & groups > Shared mailboxes.",
                    "  3. Expand Users > Active users.",
                    "  4. For each shared mailbox, ensure 'Block sign-in' is checked.",
                    "",
                    "Step 2: Review using PowerShell:",
                    "  1. Connect using Connect-ExchangeOnline.",
                    "  2. Connect using Connect-AzureAD.",
                    "  3. Run:",
                    "     $MBX = Get-EXOMailbox -RecipientTypeDetails SharedMailbox",
                    "     $MBX | ForEach {Get-AzureADUser -ObjectId $_.ExternalDirectoryObjectId} |",
                    "         Format-Table DisplayName,UserPrincipalName,AccountEnabled",
                    "  4. Ensure AccountEnabled is False for all shared mailboxes."
                )
                $joined = $steps -join "`n"
                return "MANUAL: Review shared mailboxes and ensure sign-in is blocked for all shared mailboxes.`nAudit steps:`n$joined"
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}