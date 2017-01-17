Function Get-ConsoleIP () {
    [CmdletBinding()]
    param (
        # Name of Server
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName,

        # Manufacturer
        [Parameter(Mandatory=$true)]
        [string]
        $Manufacturer
    )

    $CommonParams = @{
        ComputerName = $ComputerName
        ErrorAction = 'Stop'
    }

    Write-Verbose "$ComputerName is manufactured by $Manufacturer"
    Write-Verbose "Checking for ILO/DRAC/etc"

    Switch -wildcard ($Manufacturer) {
        "*Dell*"	{
            try {
                $DellParams = @{Namespace = 'root\cimv2\dell'}
                (Get-WmiObject Dell_RemoteAccessServicePort @CommonParams @DellParams).AccessInfo
            } catch {
                "Dell Managment Tools Not Installed"
            }
        }
        "*HP*"	{
            try {
                $HpParams = @{Namespace = 'root\HPQ'}
                (Get-WmiObject -class HP_ManagementProcessor @CommonParams @HpParams).IPAddress
            } catch {
                "HP Managment Tools Not Installed"
            }
        }
        "*VMWare*"	{ "vCenter" }
        "*Cisco*"	{ "UCS" }
        Default {"Not Found"}
    }
}