$ProjectDirectory = (Get-Item $PSScriptRoot).parent.FullName
$Module = "$ProjectDirectory\Win.ServerInformation.psd1"
$ModuleName = 'Win.ServerInformation'

Import-Module $Module

InModuleScope $ModuleName {
    $PSVersion = $PSVersionTable.PSVersion.Major
    Describe -Name "Windows Server Information PS$PSVersion" -Fixture {
        Mock Get-WmiObject {}
        Mock Get-ServerLocation {}
        Context -Name "Get-ServerData" -Fixture {
            Get-ServerData v-jenkins-pd01
            
            It "Should run GWMI on Win32_ComputerSystem once" {
                Assert-MockCalled Get-WmiObject -ParameterFilter {$class -eq 'Win32_ComputerSystem'} -Exactly 1
            }

            It "Should run GWMI on Win32_OperatingSystem once" {
                Assert-MockCalled Get-WmiObject -ParameterFilter {$class -eq 'Win32_OperatingSystem'} -Exactly 1
            }

            It "Should run GWMI on Win32_NetworkAdapterConfiguration once" {
                Assert-MockCalled Get-WmiObject -ParameterFilter {$class -eq 'Win32_NetworkAdapterConfiguration'} -Exactly 1
            }

            It "Should run Get-ServerLocation once" {
                Assert-MockCalled Get-ServerLocation -Exactly 1
            }
        }
    }
}