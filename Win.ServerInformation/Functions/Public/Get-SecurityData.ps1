Function Get-SecurityData () {
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

        Write-Verbose "Gathering System Access Policy information"
        $SystemAccessPolicy = Get-SystemAccessPolicy @CommonParams
        $SystemAccessPolicy.IP = $IP
        $SystemAccessPolicy
    } catch {
        Write-Error "Unable to Access $ComputerName"
        Write-Error $_.Exception
    }
}