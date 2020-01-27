if((Get-Date).DayOfWeek -ne "Monday")
{
    $systemEventsLog = Get-EventLog System -After (Get-Date ).AddDays(-1)  | `
    where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")}
    
    Write-Host "System Logs Id:" -BackgroundColor Green
    
    $ev = @{}
    if($systemEventsLog -ne $null)
    {
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
        Out-GridView -InputObject $ev -Title "SYSTEM EVENTS"
        Write-Host "`n"
        [int[]]$orderedEv = $ev.Keys
        
        Write-Host    ($orderedEv | sort)  -NoNewline -Separator ", "
        
        Write-Host "`n"
    }
    else
    {
        Write-Host "NO EVENTS...!!!" -BackgroundColor Magenta
    }
    
    
    

    $dnsEventsLog = Get-EventLog 'DNS Server' -After (Get-Date ).AddDays(-1) | `
    where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")} 
    
    
    Write-Host "DNS Logs Id:" -BackgroundColor Green
    if($dnsEventsLog -ne $Null)
    {
    
        $dnsEv = @{}
    
        ForEach($dnsEvent in $dnsEventsLog)
        {
            if($dnsEv[$dnsEvent.EventID])
            {
                continue;
            }
            else
            {
                $dnsEv.Add($dnsEvent.eventId , $dnsEvent.message)
            }
        
        }
    
        Out-GridView -InputObject $dnsEv -Title "DNS EVENTS"
        Write-Host "`n"
            [int[]]$orderedDNSEv = $dnsEv.Keys
    
        Write-Host    ($orderedDNSEv | sort)  -NoNewline -Separator ", "
    }
    else{Write-Host "There is no DNS Events" -BackgroundColor Green}
    
    Write-Host "`n"
}

elseif((Get-Date).DayOfWeek -eq "Monday")
{
    $startDate = (Get-Date).AddDays(-3)
    $endDate = (Get-Date)

    $systemEventsLog = Get-EventLog  System  -After (Get-Date -Date $startDate).Date  -Before (Get-Date -Date $endDate)| `
    where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")}

    Write-Host "System Logs Id:" -BackgroundColor Green
    
    $ev = @{}
    if($systemEventsLog -ne $null)
    {
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
        Out-GridView -InputObject $ev -Title "SYSTEM EVENTS"
        Write-Host "`n"
        [int[]]$orderedEv = $ev.Keys
        
        Write-Host    ($orderedEv | sort)  -NoNewline -Separator ", "
        
        Write-Host "`n"
        
    
        $dnsEventsLog = Get-EventLog 'DNS Server' -After (Get-Date -Date $startDate) -Before (Get-Date -Date $endDate)| `
        where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")} 
        
        
        
        Write-Host "DNS Logs Id:" -BackgroundColor Green
        if($dnsEventsLog -ne $Null)
        {
        
            $dnsEv = @{}
        
            ForEach($dnsEvent in $dnsEventsLog)
            {
                if($dnsEv[$dnsEvent.EventID])
                {
                    continue;
                }
                else
                {
                    $dnsEv.Add($dnsEvent.eventId , $dnsEvent.message)
                }
            }
            Out-GridView -InputObject $dnsEv -Title "DNS EVENTS"
            Write-Host "`n"
            [int[]]$orderedDNSEv = $dnsEv.Keys
        
            Write-Host    ($orderedDNSEv | sort)  -NoNewline -Separator ", "
            
        
            
        }
        else{Write-Host "There is no DNS Events" -BackgroundColor Green}
    
        Write-Host "`n"
   }
}


