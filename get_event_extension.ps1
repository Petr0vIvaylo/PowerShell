#$systemEventsLog = @{}

$systemEventsLog = Get-EventLog System -After (Get-Date ).AddDays(-1)  | `
where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical")}



$ev = @{}

ForEach($event in $systemEventsLog)
{
    if($ev[$event.EventID])
    {
        continue;
    }
    else
    {
        $ev.Add($event.eventId , $event.message)
    }
    
}

Out-GridView -InputObject $ev
Write-Host "`n"
[int[]]$orderedEv = $ev.Keys

Write-Host    ($orderedEv | sort)  -NoNewline -Separator ", "