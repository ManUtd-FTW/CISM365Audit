function Disconnect-CISM365Services {
    [CmdletBinding()]
    param(
        [string[]]$Services
    )

    if (-not $Services) {
        Write-Verbose "No specific services provided — disconnecting all known services."
        # TODO: Replace with actual disconnect logic for all services
        return
    }

    foreach ($svc in $Services) {
        try {
            Write-Verbose "Disconnecting from $svc..."
            # TODO: Replace with actual disconnect logic per service
        }
        catch {
            Write-Warning "Failed to disconnect from ${svc}: $($_.Exception.Message)"
        }
    }
}