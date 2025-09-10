function Get-CISM365Control_2_1_1 {
    [OutputType([hashtable])]
    param()

    return @{
        Id          = '2.1.1'
        Name        = 'Ensure Safe Links is configured appropriately'
        Profile     = 'L2'
        Automated   = $false
        Services    = @('Security','AdminCenter')
        Description = '...'
        Rationale   = '...'
        References  = @('https://learn.microsoft.com/...')
        Audit = {
            try {
                $mismatches = [System.Collections.Generic.List[string]]::new()

                foreach ($prop in $expectedProperties) {
                    if (-not $hasProperties.ContainsKey($prop)) {
                        # Fixed: use subexpression so the colon is not interpreted as part of the variable name
                        $mismatches.Add("$($prop): <missing>")
                    }
                }

                if ($mismatches.Count -gt 0) {
                    return "MANUAL: Missing properties:`n$($mismatches -join "`n")"
                }

                return "MANUAL: Verify Safe Links configuration per the steps..."
            }
            catch {
                return "ERROR: $($_.Exception.Message)"
            }
        }
    }
}