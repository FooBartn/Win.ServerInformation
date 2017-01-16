Purpose:
=========
This module is used to gather data from a Windows operating system

Usage:
=========
Import the module and run:
Get-ServerData -ComputerName localhost

You could use RSJobs and AD to get everything like:
```PowerShell
$Servers = Get-ADComputer -Filter {operatingsystem -Like "Windows *server*"} |
    Select-Object -ExpandProperty Name

$Servers | Start-RsJob -ScriptBlock {
    Import-Module Win.ServerInformation -ErrorAction Stop
    Get-ServerData -Name $_
}
```