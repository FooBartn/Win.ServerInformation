function Get-WinNIC {  
    param(
        # ComputerName
        [Parameter()]
        [String]
        $ComputerName = $ENV:ComputerName
    ) 

    try { 
    
        $Params = @{ 
            Class           = 'Win32_NetworkAdapter'
            Filter          = 'NetConnectionStatus = 2'
            ComputerName    = $ComputerName 
            ErrorAction     = 'Stop' 
        }

        Get-WmiObject @Params |
            Select-Object NetConnectionID, Name, MACAddress, Manufacturer

    } catch {
        Write-Warning -Message "No NICs found on $ComputerName"
    }
}
