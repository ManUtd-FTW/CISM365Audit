@{
    RootModule      = 'CISM365Audit.psm1'
    ModuleVersion   = '0.0.5'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop','Core')

    # Unique module identifier (replace with a real GUID)
    GUID            = '1a16638e-e2d3-4239-bc9e-e66e6ff36131'

    Author          = 'Omar Jimenez'
    CompanyName     = 'Virtual Innovation'
    Copyright       = '(c) Omar Jimenez. All rights reserved.'
    Description     = 'Minimal CIS Microsoft 365 Audit Module'

    # Choose one: If you want PS7+ only, use '7.2'; if you need WinPS 5.1, set that instead.
    PowerShellVersion = '7.2'

    # Keep RequiredModules empty until we finalize service dependencies per control
    # RequiredModules = @()

    FunctionsToExport = @(
        'Connect-CISM365Services',
        'Disconnect-CISM365Services',
        'Start-CISM365Audit'
    )
    CmdletsToExport   = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('PowerShell','Microsoft365','CIS','Security','Audit')
            ProjectUri   = 'https://github.com/ManUtd-FTW/CISM365Audit'
            ReleaseNotes = @'
v0.0.5
- Restructured module (Public/Private/Controls) and continued control-by-control build-out
- Hardened exports to Public entry points only
- Preparation for HTML reporting and per-control evidence objects
'@
            # Optional:
            # LicenseUri  = 'https://choosealicense.com/licenses/mit/'
            # IconUri     = 'https://raw.githubusercontent.com/.../icon.png'
        }
    }

    # Optional:
    # HelpInfoURI          = 'https://github.com/ManUtd-FTW/CISM365Audit/wiki'
    # DefaultCommandPrefix = 'CISM'
}
