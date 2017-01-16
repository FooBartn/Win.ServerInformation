Function Get-ConsoleIP ($Name,$Manufacturer) {
    Write-Verbose "$Name is manufactured by $Manufacturer"
    Write-Verbose "Checking for ILO/DRAC/etc"
    Switch -wildcard ($Manufacturer) {
        "*Dell*"	{
            try {
                $DellParams = @{
                    Namespace = 'root\cimv2\dell'
                    ComputerName = $Name
                    ErrorAction = 'Stop'
                }
                (Get-WmiObject Dell_RemoteAccessServicePort @DellParams).AccessInfo
            } catch {
                "Dell Managment Tools Not Installed"
            }
        }
        "*HP*"	{
            try {
                $HpParams = @{
                    Namespace = 'root\HPQ'
                    ComputerName = $Name
                    ErrorAction = 'Stop'
                }
                (Get-WmiObject -class HP_ManagementProcessor @HpParams).IPAddress
            } catch {
                "HP Managment Tools Not Installed"
            }
        }
        "*VMWare*"	{ "vCenter" }
        "*Cisco*"	{ "UCS" }
        Default {"Not Found"}
    }
}