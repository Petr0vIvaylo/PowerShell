Clear-DnsClientCache

$dcList = "SrvName"


foreach($dc in $dcList)
{
    $currentDC = $dc
    #Clear-DnsServerCache -ComputerName  $currentDC -Force
    try
    {
        foreach($dc in $dcList)
        {
            Resolve-DnsName $dc -DnsOnly -Server $currentDC
        }
    }
    catch
    {
        Write-Host "No Answer from $dc !!! " -BackgroundColor Red
    }
}