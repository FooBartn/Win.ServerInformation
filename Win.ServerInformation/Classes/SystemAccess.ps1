class SystemAccess {
    # Properties
    [string] $ComputerName
    [string] $IP
    [int] $PasswordComplexity
    [int] $PasswordHistorySize
    [int] $MaximumPasswordAge
    [int] $MinimumPasswordAge
    [int] $MinimumPasswordLength
    [int] $LockoutDuration
    [int] $LockoutBadCount
    [int] $ResetLockoutCount
    [int] $RequireLogonToChangePassword
    [int] $ForceLogoffWhenHourExpire
    [string] $NewAdministratorName
    [string] $NewGuestName
    [int] $ClearTextPassword
    [int] $LSAAnonymousNameLookup
    [int] $EnableAdminAccount
    [int] $EnableGuestAccount
}