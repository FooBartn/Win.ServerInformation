Function Get-AdminUserData () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName
    )

    $CommonParams = @{
        ComputerName = $ComputerName
        ErrorAction = 'Stop'
    }

    try {
        Write-Verbose "Testing connectivity with $ComputerName"
        $ServerConnection = Test-Connection $ComputerName -Count 2 -BufferSize 16 -ErrorAction Stop
        $IP = $ServerConnection[0].IPV4Address.IPAddressToString

        Write-Verbose "Gathering Admin User information"
        $AdminUserData = Get-LocalUser @CommonParams -Group Administrators
        $AdminUserData | ForEach-Object {
            $_.IP = $IP
        }
        $AdminUserData

    } catch {
        Write-Error "Unable to Access $ComputerName"
        Write-Error $_.Exception
    }
}