cls

$credentials = Get-Credential -Credential 'acc' 

$servers = "SrvName"

try
{
    Foreach ($server in $servers)
    {
        
       $disks = Get-WmiObject Win32_LogicalDisk -Credential $credentials -ComputerName $server -Filter DriveType=3 | 
                 Select-Object DeviceID, freespace
    
        $server
            
        foreach ($disk in $disks)
            {
                Write-Host $disk.DeviceID ($disk.FreeSpace/ 1GB).ToString("N2")" GB" "Free Space"
             
            }
            Write-Host "`n"
    
    }
}
catch { Write-Host "Cannot connect to server maybe behind FireWall !!! " -BackgroundColor DarkMagenta }       
     

