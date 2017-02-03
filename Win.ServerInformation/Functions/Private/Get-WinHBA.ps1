# Origian Script by Ben Wilkerson (https://social.technet.microsoft.com/profile/ben%20wilkinson/)

function Get-WinHBA {  
    param(
        # ComputerName
        [Parameter()]
        [String]
        $ComputerName = $ENV:ComputerName
    )  

    try { 
    
        $Params = @{ 
            Namespace    = 'root\WMI' 
            Class        = 'MSFC_FCAdapterHBAAttributes'  
            ComputerName = $ComputerName 
            ErrorAction  = 'Stop' 
        }
    
        Get-WmiObject @Params  | ForEach-Object {  
            $InstanceName = $_.InstanceName -replace '\\','\\' 
            $Params['class']='MSFC_FibrePortHBAAttributes' 
            $Params['filter']="InstanceName='$InstanceName'"  
            $Ports = @(Get-WmiObject @Params | 
                Select-Object -ExpandProperty Attributes | 
                ForEach-Object { 
                    ($_.PortWWN |
                        ForEach-Object {
                            "{0:x2}" -f $_
                        }
                    ) -join ":"
                }
            )

            [PsCustomObject]@{  
                WWNN                = (($_.NodeWWN) | ForEach-Object {'{0:x2}' -f $_}) -join ':' 
                WWPN                = $Ports 
                Active              = $_.Active  
                DriverName          = $_.DriverName  
                DriverVersion       = $_.DriverVersion  
                FirmwareVersion     = $_.FirmwareVersion  
                Model               = $_.Model  
                ModelDescription    = $_.ModelDescription 
                UniqueAdapterId     = $_.UniqueAdapterId 
                NumberOfPorts       = $_.NumberOfPorts 
            }
        }
    } catch { 
        Write-Warning -Message "No HBAs found on $ComputerName" 
    }
}
