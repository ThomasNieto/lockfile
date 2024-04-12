using namespace System.IO
using namespace System.Management.Automation.Runspaces

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
            Get-Content -Path $Path | ConvertFrom-Json
        } catch {
            Write-Error $_
        }
    }
}

function Set-LockFile {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Path
    )
    
    process {
        $config = @{ ComputerName = [Environment]::MachineName
            ProcessID             = $PID
            ProcessName           = (Get-Process -Id $PID).ProcessName 
        }
        
        $config | ConvertTo-Json | Out-File -FilePath $Path 
    }
}

function Test-LockFile {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, ParameterSetName = 'Path', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Path,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, ParameterSetName = 'Value', ValueFromPipelineByPropertyName)]
        [string]
        $ComputerName,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, ParameterSetName = 'Value', ValueFromPipelineByPropertyName)]
        [Alias('PID')]
        [int]
        $ProcessID,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, ParameterSetName = 'Value', ValueFromPipelineByPropertyName)]
        [string]
        $ProcessName,

        [ValidateNotNull()]
        [PSSession]
        $Session
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            try {
                $config = Get-Content -Path $Path -ErrorAction Stop | ConvertFrom-Json
            } catch {
                Write-Error $_
            }
            
            $ComputerName = $config.ComputerName
            $ProcessID = $config.ProcessID
            $ProcessName = $config.ProcessName
        }

        if ([Environment]::MachineName -ne $ComputerName -and !$PSBoundParameters.ContainsKey("Session")) {
            Write-Error "Lock file computer name '$ComputerName' does not match current computer '$([Environment]::MachineName)' and session not passed."
            return
        }
        elseif ([Environment]::MachineName -ne $ComputerName) {
            $process = Invoke-Command -Session $Session -ScriptBlock { Get-Process -Id $using:ProcessID -ErrorAction SilentlyContinue }
        }
        else {
            $process = Get-Process -Id $ProcessID -ErrorAction SilentlyContinue
        }
        
        $process.ProcessName -eq $ProcessName
    }
}
