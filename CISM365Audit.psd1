@{
    RootModule        = 'CISM365Audit.psm1'
    ModuleVersion     = '0.0.1'
    Author            = 'Omar Jimenez'
    Description       = 'Minimal CIS Microsoft 365 Audit Module'
    FunctionsToExport = @('Connect-CISM365Services',
    'Disconnect-CISM365Services',
'Start-CISM365Audit')
}
