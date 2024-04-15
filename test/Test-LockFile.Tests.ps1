#Requires -Modules LockFile

Describe 'Test-LockFile' {
    BeforeAll {
        Set-LockFile -Path TestDrive:\lock.json
    }

    It 'returns true' {
        Test-LockFile -Path TestDrive:\lock.json |
        Should -BeTrue
    }
}
