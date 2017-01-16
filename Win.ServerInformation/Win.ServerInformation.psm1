#region Public Functions
$FunctionList = Get-ChildItem -Path $PSScriptRoot\Functions\Public
foreach ($Function in $FunctionList) {
    Write-Verbose -Message ('Importing function file: {0}' -f $Function.FullName)
	. $Function.FullName
}
#endregion Public Functions

#region Private Functions
$FunctionList = Get-ChildItem -Path $PSScriptRoot\Functions\Private
foreach ($Function in $FunctionList) {
    Write-Verbose -Message ('Importing function file: {0}' -f $Function.FullName)
	. $Function.FullName
}
#endregion Private Functions