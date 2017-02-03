Function Get-ServerData () {
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

        # Gather Data
        Write-Verbose "Gathering system info for $ComputerName"
        $SystemInfo = Get-WmiObject -Class 'Win32_ComputerSystem' @CommonParams

        Write-Verbose "Gathering bios info for $ComputerName"
        $BiosInfo = Get-WmiObject -Class 'Win32_Bios' @CommonParams

        Write-Verbose "Gathering operating system info for $ComputerName"
        $OsInfo = Get-WmiObject -Class 'Win32_OperatingSystem' @CommonParams

        Write-Verbose "Gather patch info for $ComputerName"
        $PatchInfo = Get-WmiObject -Class 'Win32_QuickFixEngineering' @CommonParams |
            Where-Object {$_.InstalledOn -ne $Null} | Sort-Object -Descending InstalledOn |
            Select-Object -First 1

        Write-Verbose "Gathering DNS info for $ComputerName"
        $ServerDns = @(Get-WmiObject -Class 'Win32_NetworkAdapterConfiguration' @CommonParams | 
            Where-Object { $_.DnsServerSearchOrder } | 
        Select-Object -Expand DnsServerSearchOrder)

        Write-Verbose "Gathering Pagefile info for $ComputerName"
        $Pagefile = Get-WmiObject -Class 'Win32_PageFileUsage' @CommonParams

        Write-Verbose "Gathering WSUS info for $ComputerName"
        $WsusInfo = Get-WsusServer @CommonParams

        Write-Verbose "Gathering Console IP for $ComputerName"
        $ConsoleIP = Get-ConsoleIP @CommonParams -Manufacturer $SystemInfo.Manufacturer

        Write-Verbose "Gathering TimeZone info for $ComputerName"
        $TimeZone = (Get-WmiObject -Class 'Win32_TimeZone' @CommonParams).Caption

        Write-Verbose "Gathering NTP data for $ComputerName"
        $NtpData = Get-NtpData @CommonParams

        Write-Verbose "Gathering HBA Data for $ComputerName"
        $HBAData = Get-WinHBA @CommonParams

        Write-Verbose "Gathering NIC Data for $ComputerName"
        $NICData = Get-WinNIC @CommonParams

        # Convert Install Date
        $InstallDate = [datetime]::ParseExact($OsInfo.InstallDate.SubString(0,8),"yyyyMMdd",$null);
        $InstallDate = $InstallDate.ToShortDateString()

        # Convert Domain Role
        $DomainRole = Get-DomainRole -RoleNumber $SystemInfo.DomainRole
        
        # Assign Data To Class Params
        Write-Verbose 'Creating PSObject for Server Data'
        $ServerData = [ServerData]@{
            ComputerName            = $SystemInfo.Name
            IP                      = $IP
            OperatingSystem         = $OsInfo.Caption
            ServicePack             = $OsInfo.ServicePackMajorVersion
            LastPatchDate           = [DateTime]$PatchInfo.InstalledOn
            PagefileLocation        = $Pagefile.Name
            PagefileSize            = $Pagefile.AllocatedBaseSize 
            DnsHostName             = $SystemInfo.DnsHostName
            Domain                  = $SystemInfo.Domain
            DomainRole              = $DomainRole
            TimeZone                = $TimeZone
            NtpType                 = $NtpData.Type
            NtpServer               = $NtpData.NtpServer
            Architecture            = $OsInfo.OSArchitecture
            OutOfBandIP             = $ConsoleIP
            WsusServer              = $WsusInfo.WUServer
            WsusTargetGroup         = $WsusInfo.TargetGroup
            WsusTargetGroupEnabled  = $WsusInfo.TargetGroupEnabled
            RamGB                   = ($SystemInfo.TotalPhysicalMemory/1GB).ToString("#.##")
            PhysProcessors          = $SystemInfo.NumberOfProcessors
            LogProcessors           = $SystemInfo.NumberOfLogicalProcessors
            DNS1                    = $ServerDNS[0]
            DNS2                    = $ServerDNS[1]
            NumberOfHBAs            = $HBAData.Count
            NumberOfNICs            = $NICData.Count
            Serial                  = $BiosInfo.SerialNumber
            BiosVersion             = $BiosInfo.SMBIOSBIOSVersion
            Manufacturer            = $SystemInfo.Manufacturer
            Model                   = $SystemInfo.Model
            InstallDate             = $InstallDate
        }

        for ($Num = 0; $Num -lt $HBAData.Count; $Num++) {
            $ServerData."Hba$Num`WWNN"              = $HBAData[$Num].WWNN
            $ServerData."Hba$Num`WWPN"              = $HBAData[$Num].WWPN
            $ServerData."Hba$Num`Active"            = $HBAData[$Num].Active
            $ServerData."Hba$Num`DriverName"        = $HBAData[$Num].DriverName
            $ServerData."Hba$Num`DriverVersion"     = $HBAData[$Num].DriverVersion
            $ServerData."Hba$Num`FirmwareVersion"   = $HBAData[$Num].FirmwareVersion
            $ServerData."Hba$Num`Model"             = $HBAData[$Num].Model
            $ServerData."Hba$Num`Description"       = $HBAData[$Num].ModelDescription
            $ServerData."Hba$Num`UniqueAdapterID"   = $HBAData[$Num].UniqueAdapterID
            $ServerData."Hba$Num`NumberOfPorts"     = $HBAData[$Num].NumberOfPorts      
        }

        for ($Num = 0; $Num -lt $NICData.Count; $Num++) {
            $ServerData."Nic$Num`Name"          = $NICData[$Num].NetConnectionID
            $ServerData."Nic$Num`Device"        = $NICData[$Num].Name
            $ServerData."Nic$Num`MacAddress"    = $NICData[$Num].MACAddress
            $ServerData."Nic$Num`Manufacturer"  = $NICData[$Num].Manufacturer  
        }

        $ServerData
    } catch [System.UnauthorizedAccessException] {
        Write-Error "Authentication Failed on $ComputerName"
    } catch [System.OutOfMemoryException] {
        Write-Error "OOM. Unable to Query $ComputerName"
    } catch {
        Write-Error "Unable to Access $ComputerName"
        Write-Error $_.Exception
    }
}
