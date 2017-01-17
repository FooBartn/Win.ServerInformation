function Get-DomainRole () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $RoleNumber
    )

    switch ($RoleNumber) {
        0 {"Stand Alone Workstation"}
        1 {"Member Workstation"}
        2 {"Stand Alone Server"}
        3 {"Member Server"}
        4 {"Back-up Domain Controller"}
        5 {"Primary Domain Controller"}
        Default {"Unknown"}
    }
}