#Requires -Modules LockFile

Describe 'Get-LockFile' {
    BeforeAll {
        Set-LockFile -Path TestDrive:\lock.json
    }

    It 'returns results' {
        Get-LockFile -Path TestDrive:\lock.json |
        Should -Not -BeNullOrEmpty
    }
}
