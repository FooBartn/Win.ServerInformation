function Get-NtpData () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName
    )

    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $Win32TimeKey = 'hklm:\\system\currentcontrolset\services\w32time\parameters'
        Get-ItemProperty -Path $Win32TimeKey
    }
}