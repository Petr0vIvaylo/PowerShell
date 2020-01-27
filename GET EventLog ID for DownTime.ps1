            #month/day/year
$startDate = '01/7/2019'
$endDate = '01/8/2019'

$systemEventsLog = Get-EventLog System -After (Get-Date -Date $startDate)  -Before (Get-Date -Date $endDate)| `
where {($_.EventID  -Match 6005 ) -or ($_.EventID -Match 6008) -or ($_.EventID -match 6006)} |`
Select -Property  EventID, Message ,TimeGenerated

$systemResult = $systemEventsLog.TimeGenerated

$upTime = $null

for($i = $systemResult.Length-1; $i -gt 0; $i--){
    $upTime += NEW-TIMESPAN –Start $systemResult[$i]  –End $systemResult[$i-1]
}

 $systemEventsLog | Format-Table -Property Message, TimeGenerated

Write-Host "Total days up: "$upTime -BackgroundColor Green