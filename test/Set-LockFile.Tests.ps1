#Requires -Modules LockFile

Describe 'Set-LockFile' {
    AfterAll {
        Remove-Item TestDrive:\lock.json
    }

    It 'returns results' {
        Set-LockFile -Path TestDrive:\lock.json -PassThru |
        Should -Not -BeNullOrEmpty
    }
}
