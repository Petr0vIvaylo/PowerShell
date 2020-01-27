#Enter credentials (acc: pwd:)
    $credentials = Get-Credential

#servers that cannot establish Session
$serverDenyList = New-Object Collections.Generic.List[string]

#List of servers
$ServerList = ""

#Loop thru all listed Chiba servers
foreach($CurrentServer in $ServerList)
{
    
    

    #making session to current Server
    $s = New-PSSession -ComputerName $CurrentServer -Credential $credentials
    
    if($s -ne $null)
    {
        #Executing commands to get System and Application logs
        Invoke-Command -Session $s -ScriptBlock  {
            if(Test-Path "c:\temp\China_Sys_App_Logs.txt" -PathType Leaf)
            {
               #deleting old file if there is such one
               Remove-Item -Path "c:\temp\China_Sys_App_Logs.txt" -Force

               #create new file
               New-Item -Path "c:\temp\China_Sys_App_Logs.txt" -ItemType "file"
            }
            else 
            {
                #creating new file if not exsist
                New-Item -Path "c:\temp\China_Sys_App_Logs.txt" -ItemType "file"
            }
            
            #CurrentServerName
            $CurrentServerName = $env:COMPUTERNAME

            #Enter start and end Dates
            if(($CurrentServerName -like "SrvName") -or ($CurrentServerName -like "SrvName"))
            {
                #date format day/month/year
                $startDate = '01/11/2019'
                $endDate = '30/11/2019'
            }
            else
            {
                # date format month/day/year
                $startDate = '11/01/2019'
                $endDate = '11/30/2019'
            }
            
        
            $systemEventsLog =  Get-EventLog  System  -After (Get-Date -Date $startDate)  -Before (Get-Date -Date $endDate) | `
            where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")}
            
             Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value "SERVER: "
             Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value  $CurrentServerName
             Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value "System Logs Id:"
              
            if(($systemEventsLog -ne $null) -or ($systemEventsLog -ne ""))
            {
            
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
        
                            Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value $event.eventId
                            Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value $event.message
                            Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value "`n"
                        }
                    }
                
                    
                    
                    [int[]]$orderedEv = $ev.Keys
                    [string]$sysEvToAdd
                    foreach($data in $orderedEv)
                    {
                        $sysEvToAdd += "$data, "
                    }
        
                    Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value $sysEvToAdd 
                    Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value "`n"
            }
            else
            {
                Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value "THERE IS NO SYSTEM EVENTS"
            }
        
        
        
            $applicationEventsLog = Get-EventLog  Application -After (Get-Date -Date $startDate)  -Before (Get-Date -Date $endDate)| `
            where {($_.EntryType -Match "Error") -or ($_.EntryType -Match "Warning") -or ($_.EntryType -match "Critical") -or ($_.EntryType -match "Verbose")}
        
            Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value "Application Logs Id:"
            
            if(($applicationEventsLog -ne $null) -or ($applicationEventsLog -ne ""))
            {
            
                $evApp = @{}
                
                    ForEach($event in $applicationEventsLog)
                    {
                        if($evApp[$event.EventID])
                        {
                            continue;
                        }
                        else
                        {
                            $evApp.Add($event.eventId , $event.message)
                            Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value $event.eventId
                            Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value $event.message
                            Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value "`n"
                            
                        }
                    }
                    
                   [int[]]$orderedEvApp = $evApp.Keys
                   [string]$EvAppAdd
        
                   foreach($data in $orderedEvApp)
                   {
                       $EvAppAdd += "$data, "
                   }
        
                    Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value $EvAppAdd 
                  
            }
            else
            {
                Add-Content -path "c:\temp\China_Sys_App_Logs.txt" -value "THERE IS NO Application EVENTS ON SERVER"
            }
        } 
        remove-PSSession -Id $s.Id
    }
    else
    {
        Write-Host "Cannot connect to $CurrentServer" -BackgroundColor Red
        $serverDenyList.Add($CurrentServer)
    }
}

foreach($srv in $ServerList )
{
    if($serverDenyList -contains $srv)
    {
        continue
    }
    else
    {
        $currentLogs = Get-Content -Path "\\$srv\c$\temp\China_Sys_App_Logs.txt" 
    
        $currentLogs >> "C:\temp\China Sys App Logs\China_Sys_App_Logs_$srv.txt"
    }
}

$serverDenyList >> "C:\temp\China Sys App Logs\serversDenyList.txt"