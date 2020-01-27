$serversList = "SrvName"
$credentials = Get-Credential -Credential 'acc' 

foreach($server in $serversList)
{
    $operatingSystem = Get-WMIObject -Class win32_operatingsystem -ComputerName $server -Credential $credentials
    
    $server
    $operatingSystem.caption
   
    Write-Host "`n"
}

