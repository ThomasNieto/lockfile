# LockFile

PowerShell module to manage lock files using the current process and computer name.
This type of locking is useful in the event there is a script that needs to be highly available running on multiple computers but only one instance can be active at a time.

## Install

```powershell
# PowerShellGet
Install-Module LockFile

# PSResourceGet
Install-PSResource LockFile
```

## Usage

### Create Lock File

If creating a lock file that needs to be read from multiple machines use a shared path.

```powershell
Set-LockFile -Path \\scripts\myscript.lock
```

### Get Lock File

To get the configuration of the lock file.

```powershell
Get-LockFile -Path \\scripts\myscript.lock

ComputerName ProcessId ProcessName
------------ --------- -----------
TestDC            4800 pwsh
```

### Test Lock File Validity

```powershell
Test-FileLock -Path \\scripts\myscript.lock
```

You can also pipe the outputs from `Get-LockFile`.

```powershell
Get-LockFile -Path \\scripts\myscript.lock | Test-FileLock
True
```

If the process that created the lock is on another computer
create a session to the computer for the cmdlet to check the validity.

```powershell
$lock = Get-LockFile -Path \\scripts\myscript.lock

$results = if ($env:ComputerName -ne $lock.ComputerName) {
    $session = New-PSSession -ComputerName TestDC2
    $lock | Test-LockFile -Session $session
} else {
    $lock | Test-LockFile -Session
}

$results
True
```
