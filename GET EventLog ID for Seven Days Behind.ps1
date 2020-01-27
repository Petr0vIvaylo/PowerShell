
[datetime]$todayDate = get-date -Format "MM/dd/yyyy"
$weekBefore = $todayDate.AddDays(-8)

$serversList = 

$systemEventsLog = Get-EventLog System -After (Get-Date -Date $weekBefore)  -Before (Get-Date -Date $todayDate)| `
where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")} |`
Select -Property  {$_.EventID} -Unique

[string[]]$systemResult = $systemEventsLog

Write-Host "System Logs Id:" -BackgroundColor Green

ForEach($sysId in $systemResult)
{
    Write-Host  $sysId.Trim("@","{","$","_",".","E","v","e","n","t","I","D","=","}"," "  )-NoNewline ","
}

Write-Host "`n"

