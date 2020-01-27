
$startDate = '10/01/2019'
$endDate = '10/31/2019'


        $systemEventsLog = Get-EventLog  System  -After (Get-Date -Date $startDate)  -Before (Get-Date -Date $endDate)| `
    where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical")} |`
    Select -Property  EventID -Unique
    
    [string[]]$systemResult = $systemEventsLog
    
    Write-Host "$env:COMPUTERNAME System Logs Id:" -BackgroundColor Green
    
    ForEach($sysId in $systemResult)
    {
        Write-Host  $sysId.Trim("@","{","$","_",".","E","v","e","n","t","I","D","=","}"," "  )-NoNewline ","
    }
    
    Write-Host "`n"
    
    $applicationEventsLog = Get-EventLog  Application -After (Get-Date -Date $startDate)  -Before (Get-Date -Date $endDate)| `
    where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical")} |`
    Select -Property  {$_.EventID } -Unique
    
    [string[]]$aplicationResult = $applicationEventsLog
    
    Write-Host "Application Logs Id:" -BackgroundColor Green
    
    ForEach($appId in $aplicationResult)
    {
        Write-Host $appId.Trim("@","{","$","_",".","E","v","e","n","t","I","D","=","}"," "  )-NoNewline ","
    }
    
    Write-Host "`n"
    


