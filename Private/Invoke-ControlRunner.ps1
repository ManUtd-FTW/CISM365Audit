function Invoke-ControlRunner {
    [CmdletBinding()]
    param()

    $results = @()
    $results += Test-CismGlobalAdmins
    $results += Test-CismDkimEnabled
    $results += Test-CismSafeLinksEnabled
    return $results
}
