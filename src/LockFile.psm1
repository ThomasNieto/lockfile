using namespace System.IO

function Get-LockFile {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [ValidateSet('Csv', 'Json')]
        [string]
        $Format
    )

    end {
        if (!$PSBoundParameters.ContainsKey('Format')) {
            $Format = [Path]::GetExtension($Path) -replace '\.', ''
        }
        
        switch ($Format) {
            'Csv' { Import-Csv -Path $Path }
            'Json' { Get-Content -Path $Path | ConvertFrom-Json }
            default { throw 'Invalid file extension' }
        }
    }
}

function Set-LockFile {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [ValidateSet('Csv', 'Json')]
        [string]
        $Format
    )
    
    end {
        if (!$PSBoundParameters.ContainsKey('Format')) {
            $Format = [Path]::GetExtension($Path) -replace '\.', ''
        }
        
        $config = @{ ComputerName = [Environment]::MachineName
                     PID          = $PID
                     ProcessName  = (Get-Process -Id $PID).ProcessName 
        }
        
        switch ($Format) {
            'Csv' { $config | Export-Csv -Path $Path }
            'Json' { $config | ConvertTo-Json | Out-File -FilePath $Path }
            default { throw 'Invalid file extension' }
        }
    }
}

function Test-LockFile {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [ValidateSet('Csv', 'Json')]
        [string]
        $Format
    )

    end {
        if (!$PSBoundParameters.ContainsKey('Format')) {
            $Format = [Path]::GetExtension($Path) -replace '\.', ''
        }
        
        $config = switch ($Format) {
            'Csv' { Import-Csv -Path $Path }
            'Json' { Get-Content -Path $Path | ConvertFrom-Json }
            default { throw 'Invalid file extension' }
        }

        if ([Environment]::MachineName -eq $config.ComputerName) {
            if ((Get-Process -Id $config.PID -ErrorAction SilentlyContinue).ProcessName -eq $config.ProcessName) {
                $true
            } else {
                $false
            }
        } else {
            # TODO: Flex for WinRM and SSH as -ComputerName parameter doesn't exist on PS7
            if ((Get-Process -ComputerName $config.ComputerName -Id $config.PID -ErrorAction SilentlyContinue).ProcessName -eq $config.ProcessName) {
                $true
            } else {
                $false
            }
        }
    }
}
