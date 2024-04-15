using namespace System.Management.Automation.Runspaces

class LockFile {
    [string] $ComputerName
    [int] $ProcessId
    [string] $ProcessName
}

<#
    .SYNOPSIS
    Gets lock file information.

    .DESCRIPTION
    Gets lock file information containing ComputerName, ProcessId, and ProcessName.

    .PARAMETER Path
    Specifies the path to the lock file.

    .EXAMPLE
    Get-LockFile -Path C:\scripts\lock.json
    
    ComputerName ProcessId ProcessName
    ------------ --------- -----------
    TestDC           28864 pwsh

    Gets the lock file in path 'C:\scripts\lock.json' and returns the information of the lock.
#>
function Get-LockFile {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Path
    )

    process {
        try {
            [LockFile] $config = Get-Content -Path $Path |
                ConvertFrom-Json
        } catch {
            Write-Error $_
            return
        }

        $config
    }
}

<#
    .SYNOPSIS
    Sets a lock file.

    .DESCRIPTION
    Sets lock file containing ComputerName, ProcessId, and ProcessName.

    .PARAMETER Path
    Specifies the path to the lock file.

    .PARAMETER PassThru
    Specifies if the lock file information should be returned.

    .EXAMPLE
    Set-LockFile -Path C:\scripts\lock.json -PassThru
    
    ComputerName ProcessId ProcessName
    ------------ --------- -----------
    TestDC           28864 pwsh

    Sets the lock file in path 'C:\scripts\lock.json' and returns the information of the lock.
#>
function Set-LockFile {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Path,

        [switch]
        $PassThru
    )
    
    process {
        $config = [LockFile]@{
            ComputerName = [Environment]::MachineName
            ProcessId    = $PID
            ProcessName  = (Get-Process -Id $PID).ProcessName 
        }
        
        try {
            $config |
                ConvertTo-Json |
                Out-File -FilePath $Path
        } catch {
            Write-Error $_
            return
        }

        if ($PassThru) {
            $config
        }
    }
}

<#
    .SYNOPSIS
    Tests a lock file.

    .DESCRIPTION
    Tests a lock file to validate if it is still valid.

    .PARAMETER Path
    Specifies the path to the lock file.

    .PARAMETER InputObject
    Specifies the lock file information from Get-LockFile.

    .PARAMETER Session
    Specifies the PSSession to connect remotely to check lock file on another computer.

    .EXAMPLE
    Test-LockFile -Path C:\scripts\lock.json
    True

    Tests the lock file in path 'C:\scripts\lock.json' and returns true if valid.

    .EXAMPLE
    Test-LockFile
    True

    Tests the lock file in path 'C:\scripts\lock.json' and returns true if valid.
#>
function Test-LockFile {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([bool])]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, ParameterSetName = 'Path', Position = 0, ValueFromPipeline)]
        [string]
        $Path,

        [ValidateNotNull()]
        [Parameter(Mandatory, ParameterSetName = 'InputObject', ValueFromPipeline)]
        [LockFile]
        $InputObject,

        [ValidateNotNull()]
        [PSSession]
        $Session
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            try {
                $InputObject = Get-Content -Path $Path -ErrorAction Stop |
                    ConvertFrom-Json
            } catch {
                Write-Error $_
                return
            }
        }

        if ([Environment]::MachineName -ne $InputObject.ComputerName -and !$PSBoundParameters.ContainsKey('Session')) {
            Write-Error "Lock file computer name '$($InputObject.ComputerName)' does not match current computer '$([Environment]::MachineName)' and session not passed."
            return
        } elseif ([Environment]::MachineName -ne $InputObject.ComputerName) {
            $process = Invoke-Command -Session $Session -ScriptBlock { Get-Process -Id $using:InputObject.ProcessId -ErrorAction SilentlyContinue }
        } else {
            $process = Get-Process -Id $InputObject.ProcessId -ErrorAction SilentlyContinue
        }
        
        $process.ProcessName -eq $InputObject.ProcessName
    }
}
