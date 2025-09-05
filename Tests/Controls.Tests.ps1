# Requires: Pester 5.x
Describe 'CISM365 Control Validation' {
    $controlsPath = Join-Path $PSScriptRoot '..\Private\Controls'
    $controlFiles = Get-ChildItem -Path $controlsPath -Filter 'Control.*.ps1' -File

    $catalog = @()
    foreach ($file in $controlFiles) {
        . $file.FullName
    }
    $factories = Get-Command -Name 'Get-CISM365Control_*' -CommandType Function
    foreach ($f in $factories) {
        $catalog += & $f.Name
    }

    It 'All controls have required fields' {
        foreach ($ctrl in $catalog) {
            $ctrl.Id          | Should -Not -BeNullOrEmpty
            $ctrl.Name        | Should -Not -BeNullOrEmpty
            $ctrl.Profile     | Should -Match '^(L1|L2)$'
            $ctrl.Automated   | Should -BeOfType 'System.Boolean'
            $ctrl.Services    | Should -BeOfType 'System.Object[]'
            $ctrl.Description | Should -Not -BeNullOrEmpty
            $ctrl.Rationale   | Should -Not -BeNullOrEmpty
            $ctrl.References  | Should -BeOfType 'System.Object[]'
            $ctrl.Audit       | Should -BeOfType 'System.Management.Automation.ScriptBlock'
        }
    }

    It 'Control IDs are unique' {
        $ids = $catalog.Id
        $ids.Count | Should -Be ($ids | Select-Object -Unique).Count
    }

    It 'Services values are valid' {
        $validServices = 'Graph','ExchangeOnline','Teams','SharePoint','Compliance'
        foreach ($ctrl in $catalog) {
            foreach ($svc in $ctrl.Services) {
                $svc | Should -BeIn $validServices
            }
        }
    }
}