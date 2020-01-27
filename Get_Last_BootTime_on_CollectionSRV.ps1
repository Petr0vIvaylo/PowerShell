$servers = "SrvName"

$credentials = Get-Credential "acc"
$serversInfo = @{}
foreach($server in $servers){

    $lastootTimeInfo = Get-WmiObject win32_operatingsystem -ComputerName $server -Credential $credentials |`
    select csname, @{LABEL=’LastBootUpTime’;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
  
    $serversInfo.add($lastootTimeInfo.csname, $lastootTimeInfo.LastBootUpTime)

 }

 $serversInfo

 
 
  