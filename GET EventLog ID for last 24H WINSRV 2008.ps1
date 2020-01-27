
    $systemEventsLog = Get-EventLog System -After (Get-Date ).AddDays(-1)| `
    where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")} |`
    Select -Property  {$_.EventID} -Unique
    
    [string[]]$systemResult = $systemEventsLog
    
    Write-Host "System Logs Id:" -BackgroundColor Green
    if($systemEventsLog -ne $null)
        {
            ForEach($sysId in $systemResult)
            {
                Write-Host  $sysId.Trim("@","{","$","_",".","E","v","e","n","t","I","D","=","}"," "  )-NoNewline ","
            }
            
            Write-Host "`n"
            
            
        }           
    else
        {
            Write-Host "NO EVENTS...!!!" -BackgroundColor Magenta
        }
        
        
    
        $dnsEventsLog = Get-EventLog 'DNS Server' -After (Get-Date ).AddDays(-1)| `
    where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")} |`
    Select -Property  {$_.EventID} -Unique
        
        
        Write-Host "DNS Logs Id:" -BackgroundColor Green
        if($dnsEventsLog -ne $Null)
        {
            [string[]]$dnsResult = $dnsEventsLog
    
            Write-Host "System Logs Id:" -BackgroundColor Green
             
            ForEach($sysId in $dnsResult)
            {
                Write-Host  $dnsId.Trim("@","{","$","_",".","E","v","e","n","t","I","D","=","}"," "  )-NoNewline ","
            }
            
            Write-Host "`n"
                          
                    
         
        }
        else{Write-Host "There is no DNS Events" -BackgroundColor Green}
        
        





