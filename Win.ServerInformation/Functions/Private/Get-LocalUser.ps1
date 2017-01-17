Function Get-LocalUser  {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName,

        [Parameter(Mandatory=$true)]
        [string]
        $Group
    )

    # Get Group Members
    $ADSIGroup =[ADSI]"WinNT://$ComputerName/$Group" 
	$ADSIGroupCollection = @($ADSIGroup.psbase.Invoke("Members"))
    $ADSIGroupMembers = $ADSIGroupCollection | 
    ForEach-Object {
        $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }

    # Get Individual Member Data
    $ADSI = [ADSI]"WinNT://$ComputerName"
    $adsi.Children | Where-Object {
        $_.SchemaClassName -eq 'user' -and
        $ADSIGroupMembers -contains $_.Name[0]
    } | 
    ForEach-Object {
        [UserData]@{
            ComputerName = $ComputerName
            UserName = $_.Name[0]
            Description = $_.Description[0]
            SID = ConvertTo-SID -BinarySID $_.ObjectSID[0]
            PasswordAge = [math]::Round($_.PasswordAge[0]/86400)
            LastLogin = If ($_.LastLogin[0] -is [datetime]){
                $_.LastLogin[0]
            } Else {
                'Never logged on'
            }
            UserFlags = Convert-UserFlag -UserFlag $_.UserFlags[0]
            BadPasswordAttempts = $_.BadPasswordAttempts[0]
            MaxBadPasswords = $_.MaxBadPasswordsAllowed[0]
        }
    }
}