Purpose:
=========
This module is used to gather data from a Windows operating system

Usage:
=========
Examples:
- Get-ServerData -ComputerName localhost -Verbose
- Get-SecurityData -ComputerName localhost -Verbose
- Get-AdminUserData -ComputerName localhost -Verbose

You could use PoSHRSJobs and AD to get everything like:
```PowerShell
$Servers = Get-ADComputer -Filter {operatingsystem -Like "Windows *server*"} |
    Select-Object -ExpandProperty Name

$Servers | Start-RSJob -ScriptBlock {
    Import-Module Win.ServerInformation -ErrorAction Stop
    Get-ServerData -Name $_
}
```