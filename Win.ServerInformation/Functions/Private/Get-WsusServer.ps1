function Get-WsusServer () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName
    )

    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $WinUpdateKey = 'hklm:\\software\policies\microsoft\windows\windowsupdate'
        Get-ItemProperty -Path $WinUpdateKey
    }
}