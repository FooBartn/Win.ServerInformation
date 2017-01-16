Function Get-ServerData () {
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
        $ServerConnection = Test-Connection $ComputerName -Count 2 -BufferSize 16 -ErrorAction Stop
        $IP = $ServerConnection[0].IPV4Address.IPAddressToString

        # Gather Data
        Write-Verbose "Gathering system info for $ComputerName"
        $SystemInfo = Get-WmiObject -Class 'Win32_ComputerSystem' @CommonParams

        Write-Verbose "Gathering operating system info for $ComputerName"
        $OsInfo = Get-WmiObject -Class 'Win32_OperatingSystem' @CommonParams

        Write-Verbose "Gathering DNS info for $ComputerName"
        $ServerDns = @(Get-WmiObject -Class 'Win32_NetworkAdapterConfiguration' @CommonParams | 
            Where-Object { $_.DnsServerSearchOrder } | 
        Select-Object -Expand DnsServerSearchOrder)

        Write-Verbose "Gathering Pagefile info for $ComputerName"
        $Pagefile = Get-WmiObject -Class 'Win32_PageFileUsage' @CommonParams

        $InstallDate = [datetime]::ParseExact($OsInfo.InstallDate.SubString(0,8),"yyyyMMdd",$null);
        $InstallDate.ToShortDateString()
        
        # Assign Data To Class Params
        Write-Verbose 'Creating PSObject for Server Data'
        [ServerData]@{
            Name = $ComputerName
            IP = $IP
            OperatingSystem = $OsInfo.Caption
            ServicePack = $OsInfo.ServicePackMajorVersion
            PagefileLocation = $Pagefile.Name
            PagefileSize = $Pagefile.AllocatedBaseSize 
            DnsHostName = $SystemInfo.DnsHostName
            Domain = $SystemInfo.Domain
            Architecture = $OsInfo.OSArchitecture
            OutOfBandIP = Get-ConsoleIP $ComputerName $SystemInfo.Manufacturer
            RamGB = ($SystemInfo.TotalPhysicalMemory/1GB).ToString("#.##")
            PhysProcessors = $SystemInfo.NumberOfProcessors
            LogProcessors = $SystemInfo.NumberOfLogicalProcessors
            DNS1 = $ServerDNS[0]
            DNS2 = $ServerDNS[1]
            Serial = (Get-WmiObject -Class "Win32_Bios" @CommonParams).SerialNumber
            Manufacturer = $SystemInfo.Manufacturer
            Model = $SystemInfo.Model
            InstallDate = $InstallDate
        }
    } catch [System.UnauthorizedAccessException] {
        Write-Error "Authentication Failed on $ComputerName"
    } catch [System.OutOfMemoryException] {
        Write-Error "OOM. Unable to Query $ComputerName"
    } catch {
        Write-Error "Unable to Access $ComputerName"
        Write-Error $_.Exception
    }
}