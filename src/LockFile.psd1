@{
    RootModule           = 'LockFile.psm1'
    ModuleVersion        = '0.1.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID                 = '83cf1001-3729-4b62-a3e7-f7107787afb9'
    Author               = 'Thomas Nieto'
    Copyright            = '(c) Thomas Nieto. All rights reserved.'
    Description          = 'Create and manage lock files.'
    PowerShellVersion    = '5.1'
    FunctionsToExport    = @('Get-LockFile', 'Set-LockFile', 'Test-LockFile')
    CmdletsToExport      = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags       = @('Lock', 'File', 'LockFile')
            LicenseUri = 'https://github.com/ThomasNieto/lockfile/blob/main/LICENSE'
            ProjectUri = 'https://github.com/ThomasNieto/lockfile'
        }

    }
}
