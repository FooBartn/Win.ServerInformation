function Get-SystemAccessPolicy () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName
    )

    $SecurityObject = [SystemAccess]@{
        ComputerName = $ComputerName
    }

    $RawData = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $TempFile = 'C:\SecEdit_Temp.txt'
        SecEdit /export /cfg $TempFile
        Get-Content -Path $TempFile
        Remove-Item -Path $TempFile -Force
    }

    $StartingLine = ($RawData | Select-String 'System Access').LineNumber
    $EndingLine = ($RawData | Select-String 'Event Audit').LineNumber - 2

    for ($i = $StartingLine; $i -le $EndingLine; $i++) {
        $Policy,$Value = $RawData[$i].Split('=').Trim()
        $SecurityObject.$Policy = $Value
    }

    $SecurityObject
}