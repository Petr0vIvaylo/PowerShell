$operatingSystem = (Get-WMIObject win32_operatingsystem).name
if(!($operatingSystem -like "*Microsoft Windows Server 2016*"))
{
    Write-Host "Noob!!! само за сървър 2016-ка брат"
    exit
}
else
{
    
    #Configure Time settings:
    cls
    do
    {
        
        $timeZone = Read-Host "Дай ми часова зона e.g(Singapore Standard Time)"
        try
        {
            set-TimeZone -Id $timeZone
            $getTimeZone = Get-TimeZone
            cls
        }
        catch {Write-Host "Бастун дай валидна часова зона..." -BackgroundColor Red}
    }
    while($timeZone -ne ($getTimeZone.Id ))

    $report =[ordered]@{}

    $report.Add("Language", $culture.DisplayName)
    $report.Add("Keyboard", $culture.Name)

    $culture = Get-Culture
    $culture.DateTimeFormat.FirstDayOfWeek = "Monday"
    $culture.DateTimeFormat.ShortDatePattern = "dd-MMM-yy"
    $culture.DateTimeFormat.LongDatePattern = "dddd, d MMMM, yyyy"
    $culture.DateTimeFormat.LongTimePattern = "HH:mm:ss"
    Set-Culture $culture
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value "HH:mm" -Force
    
    $shortTime = get-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime"
    $report.Add("First day of week", $culture.DateTimeFormat.FirstDayOfWeek)
    $report.Add("Short date",        $culture.DateTimeFormat.ShortDatePattern)
    $report.Add("Long date",         $culture.DateTimeFormat.LongDatePattern)
    $report.Add("Short time",        $shortTime.sShortTime)
    $report.Add("Long time",         $culture.DateTimeFormat.LongTimePattern)
    
    
    #System Configuration:
    
    #Control Panel / System and Security / System / Advanced System settings 
    	      #/ Performance Settings / Advanced /Virtual memory/ 
    	      #Change: Set to “Automatically manage paging file size for all drives”
    $sys = Get-WmiObject win32_computersystem -EnableAllPrivileges
    $sys.AutomaticManagedPagefile = $true
    $sys.Put()
    $report.Add("AutomaticManagedPagefile", $sys.AutomaticManagedPagefile)
    
    
    #Control Panel / System and Security / System / Advanced System Settings 
                  #/ Advanced / Performance / Processor Scheduling / Set to Background Services.
    Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 2
    $backgroundServices = get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation  
    $report.Add("Background Services", $backgroundServices.Win32PrioritySeparation)
    
    
    #Control Panel / System / Advanced System Properties / Startup and Recovery Settings:
    $regkeypath="HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl"

     #Time to display list of operating systems
     bcdedit /timeout 15
     #System Failure Auto Reboot
     Set-ItemProperty -Path $regkeypath -Name "AutoReboot" -Value 1
     #Write Debugging Info
     Set-ItemProperty -Path $regkeypath -Name "CrashDumpEnabled" -Value 2
     #Overwrite any existing file
     Set-ItemProperty -Path $regkeypath -Name "Overwrite" -Value 0
    
    [array]$disks = Get-WmiObject Win32_LogicalDisk  -Filter DriveType=3 | 
                     Select-Object DeviceID
    if($disks.Count -gt 1)
    {
    	Set-ItemProperty -Path $regkeypath -Name "DumpFile" -Value "E:\memory.dmp"
    }
    else
    {
        Set-ItemProperty -Path $regkeypath -Name "DumpFile" -Value "%SystemRoot%\MEMORY.DMP"
    }


    $SystemFailureAutoReboot = get-ItemProperty -Path $regkeypath -Name "AutoReboot"
    $WriteDebuggingInfo = get-ItemProperty -Path $regkeypath -Name "CrashDumpEnabled"
    $Overwriteanyexistingfile = get-ItemProperty -Path $regkeypath -Name "Overwrite"
    $DumpFile = get-ItemProperty -Path $regkeypath -Name "DumpFile"

    $report.Add("Time to display list of operating system", 15)
    $report.Add("System failure / Automatically restart", $SystemFailureAutoReboot.AutoReboot)
    $report.Add("Write Debugging Info", $WriteDebuggingInfo.CrashDumpEnabled)
    $report.Add("Overwrite any existing file", $Overwriteanyexistingfile.Overwrite)
    $report.Add("Dump file", $DumpFile.DumpFile)

    #Start / Local Security Policy - expand Local Policies and choose Audit Policy. Then configure it as follows:
    auditpol /set /category:"Account Logon","Account Management","Logon/Logoff","Policy Change","Detailed Tracking","System" /success:enable /failure:enable
    auditpol /set /category:"DS Access","Object Access" /success:disable /failure:enable
    auditpol /set /category:"Privilege Use" /success:enable /failure:disable
    
    #GET ALL CATEGORY
    #auditpol /get /Category:*
    $accountLog = auditpol /get /category:"Account Logon"
    $accountManagement = auditpol /get /category:"Account Management"
    $Logon_off = auditpol /get /category:"Logon/Logoff"
    $policyChange = auditpol /get /category:"Policy Change"
    $detailedTracking = auditpol /get /category:"Detailed Tracking"
    $system = auditpol /get /category:"System"
    $dsAccess = auditpol /get /category:"DS Access"
    $objectAccess = auditpol /get /category:"Object Access"
    $privilegeUse = auditpol /get /category:"Privilege Use"
    
    $report.Add("Account Logon", $accountLog)
    $report.Add("Account Management",$accountManagement)
    $report.Add("Logon/Logoff", $Logon_off)
    $report.Add("Policy Change", $policyChange)
    $report.Add("Detailed Tracking", $detailedTracking)
    $report.Add("System", $system)
    $report.Add("DS Access", $dsAccess)
    $report.Add("Object Access", $objectAccess )
    $report.Add("Privilege Use", $privilegeUse)
    
    #Server Manager / Tools / Event Viewer / Windows Logs – Expand Event View. 
    #Choose consecutively Application, Security, Setup, System and Forwarded Event logs,
    # then right-click each log and click Properties:
    Limit-Eventlog -Logname Application -MaximumSize 262144KB -OverflowAction OverwriteAsNeeded
    Limit-Eventlog -Logname Security -MaximumSize 262144KB -OverflowAction OverwriteAsNeeded
    Limit-Eventlog -Logname System -MaximumSize 262144KB -OverflowAction OverwriteAsNeeded
    $SetupLog = Get-WinEvent -ListLog Setup 
    $SetupLog.MaximumSizeInBytes = 262144KB
    $SetupLog.LogMode = 0
    $SetupLog.SaveChanges()
    
    #adding eventlogs to report
    $SystemLog = Get-WinEvent -ListLog system 
    $applicationLog = Get-WinEvent -ListLog application
    $securityLog = get-WinEvent -ListLog security
    $report.Add("System Log", @{maxSize=$SystemLog.MaximumSizeInBytes/1024 ; logType = $SystemLog.LogMode})
    $report.Add("Application Log", @{maxSize= $applicationLog.MaximumSizeInBytes/1024 ; logType = $applicationLog.LogMode})
    $report.Add("Security", @{maxSize= $securityLog.MaximumSizeInBytes/1024 ; logType = $securityLog.LogMode})
    
    
    
    #Open Server Manager (from the Taskbar) / 
    #Click on Add Roles and Features and select ”SNMP Service” from the Features sub-menu. 
    #Choose Next and then install.
    
    #Check If SNMP Services Are Already Installed
    Import-Module ServerManager
        $SNMP_check = Get-WindowsFeature | Where-Object {$_.Name -like "*SNMP*"}
    If ($SNMP_check.Installed -ne "True" -or $SNMP_check.Installed -eq $null) {
    	
        #Install/Enable SNMP Services
    	Install-WindowsFeature SNMP-Service -IncludeManagementTools
        
        #Add SNMP_service to report
        $SNMP_Service = Get-WindowsFeature | Where-Object {$_.Name -like "*SNMP*"}
        $report.Add("SNMP_Service", $SNMP_Service)
    }
    Else {$report.Add("SNMP_Service", $SNMP_check)}

    ######################################################
    $RSAT_AD_PowerShell = Get-WindowsFeature | Where-Object {$_.Name -like "*RSAT-AD-PowerShell*"}
    if($RSAT_AD_PowerShell.Installed -ne $true)
    {
        install-WindowsFeature RSAT-AD-PowerShell
        $RSAT_AD_PowerShell = Get-WindowsFeature | Where-Object {$_.Name -like "*RSAT-AD-PowerShell*"}
        $report.Add("RSAT_AD_PowerShell", $RSAT_AD_PowerShell)
    }
    Else {$report.Add("RSAT_AD_PowerShell", $RSAT_AD_PowerShell)}
    ######################################################
    $rsat_adds = Get-WindowsFeature | Where-Object {$_.Name -like "*rsat-adds*"}
    if($rsat_adds.Installed -ne $true)
    {
        Install-WindowsFeature rsat-adds -IncludeManagementTools
        $rsat_adds = Get-WindowsFeature | Where-Object {$_.Name -like "*rsat-adds*"}
        $report.Add("rsat_adds", $rsat_adds)
    }
    Else {$report.Add("rsat_adds", $rsat_adds)}
    ######################################################
    $rsat_adlds = Get-WindowsFeature | Where-Object {$_.Name -like "*rsat-adds*"}
    if($rsat_adlds.Installed -ne $true)
    {
        Install-WindowsFeature rsat-adlds
        $rsat_adlds = Get-WindowsFeature | Where-Object {$_.Name -like "*rsat-adds*"}
        $report.Add("rsat_adlds", $rsat_adlds)
    }
    Else {$report.Add("rsat_adlds", $rsat_adlds)}
    ######################################################
    
    
    #Disabling Windows Firewall:
    #- Control Panel\System and Security\Windows Firewall\ Advanced Settings 
    #\ Windows Firewall Properties 
    #\  set “Firewall state: Off” for “Domain”, “Private” and “Public”.
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    $fireWallProfile = get-NetFirewallProfile -Profile Domain,Public,Private | Select-Object -Property Enabled
    $report.Add("FirewallProfile-Domain", $fireWallProfile[0])
    $report.Add("FirewallProfile-Public", $fireWallProfile[1])
    $report.Add("FirewallProfile-Private", $fireWallProfile[2])

    #Set Windows Update service to Manual (Stopped) - in order to avoid downloading Windows updates from Internet
    $regKeypathServices =  Get-Service wuauserv
    Set-Service -InputObject $regKeypathServices -StartupType Manual 
    
    try
    { 
        $regKeypathServices.Stop()
         $report.Add($regKeypathServices.DisplayName, "Service StartUP Type:" + $regKeypathServices.StartType + " / Service Status:" +$regKeypathServices.Status)
    }
    catch
    {
        $report.Add($regKeypathServices.DisplayName, "Service StartUP Type:" + $regKeypathServices.StartType + " / Service Status:" +$regKeypathServices.Status)
    }
     
    #Checking for Windows Defender:
    
    $checkDefender = Get-WindowsFeature | Where-Object {$_.Name -like "*defender*"}
    If ($checkDefender.Installed -ne "True") 
    {
    	$report.Add("Windows Defender", "Windows Defender not installed")
    }
    else
    {
    #Real Time Protection – Off
    	Set-MpPreference -DisableRealtimeMonitoring $true 
    #Cloud-based Protection – Off
        Set-MpPreference -MAPSReporting Disabled
    #Automatic Sample Submission – Off
        Set-MpPreference -SubmitSamplesConsent None
    # ENCHANCED NOTIFICATIONS  OFF
    new-Item -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Reporting"
    new-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Reporting" -Name DisableEnhancedNotifications -PropertyType dword -Value 0 
    }
    
    
    #Allow remote connections to this computer
    # 0 - set Allow RDP / 1 -Deny RDP   --> "fDenyTSConnections"
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "AllowRemoteRPC" –Value 1
    
    #Disable NetBios in WINS tab
    $QryNetAdapterConfigs = "Select * from Win32_NetworkAdapterConfiguration where IPEnabled = True"
    $NetAdapterConfigs = Get-WMIObject -query $QryNetAdapterConfigs
    $NetAdapterConfigs.SetTcpipNetbios(2)
    
    
    
    #Disable NetBIOS over TCP/IP
    $nicClass = Get-WmiObject -list Win32_NetworkAdapterConfiguration
    $nicClass.enablewins($false,$false)
    
    
    #Disable  IPv6 using the Registry Editor (regedit).
    New-ItemProperty “HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\” -Name “DisabledComponents” -Value 0xffffffff -PropertyType “DWord"
    #uncheck network adapter ipV6
    Get-NetAdapterBinding -ComponentID "ms_tcpip6" | disable-NetAdapterBinding -ComponentID "ms_tcpip6" –PassThru

    #Disable User Account Settings (UAC) using the Registry Editor (regedit).
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 1 -Force
    
    
    #Go to the Local Computer Policy management snap-in (gpedit.msc) – then perform the following modifications:
    #Computer Configuration>Administrative Templates>Windows Components>
    #Remote Desktop Services>Remote Desktop Session Host> Session Time Limits and set the following limits:
    
    #Set time limit for disconnected sessions
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxDisconnectionTime -Value 7200000
    
    #Set time limit for active but idle Remote Desktop Services sessions
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxIdleTime -value 0
    
    #Set time limit for active Remote Desktop Services sessions
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name  MaxConnectionTime -Value 0
    
    
    #Computer Configuration>Administrative Templates>Windows Components>Remote Desktop Services>
    #Remote Desktop Session Host >Device and Resource Redirection:
    #Allow audio and video playback redirection -> Disabled
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCam -Value 1
    
    #Allow audio recording redirection ---> Disabled
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableAudioCapture -Value 1
    
    #Do not allow COM port redirection  --->  Enabled
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCcm -Value 1
    
    #Do not allow drive redirection ---> Enabled
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCdm -Value 1
    
    #Do not allow LPТ port redirection --->  Enabled
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableLPT -Value 1
    
    #Do not allow supported Plug and Play device redirection  ---> Enabled
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisablePNPRedir -Value 1
    
    
    #Computer Configuration>Administrative Templates>Windows Components>Remote Desktop Services>Remote Desktop Session Host > 
    #Remote Session Environment
    
    #Limit maximum color depth --->  Enabled   --> 16 bit
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name ColorDepth -Value 3
    
    #Always show desktop on connection  --> Enabled
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fTurnOffSingleAppMode -Value 1
    
    
    
    #Computer Configuration>Administrative Templates>Windows Components>Remote Desktop Services>
    #Remote Desktop Session Host>Connections
    
    #Set rules for remote control of Remote Desktop Services user sessions  --->  Enabled
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name Shadow -Value 1
    
    
    #Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update. Perform the following changes: 
    #Registry values are located -> regedit\ HKEY_LOCAL_MACHINE(HKLM)\Software\Policies\Microsoft\Windows\WindowsUpdate\AU
    #AUOption value should be = 3
    Set-ItemProperty -path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name AUOptions -Value 3
    
    #No auto-restart with logged on users for scheduled automatic updates installations” – set Enabled.
    #Registry values are located -> regedit\ HKEY_LOCAL_MACHINE(HKLM)\Software\Policies\Microsoft\Windows\WindowsUpdate\AU
    #NoAutoRebootWithLoggedOnUsers = 1
    Set-ItemProperty -path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoRebootWithLoggedOnUsers -Value 1
    
    #Disable Reboot Task
    #Go to Control Panel -> System and Security -> Administrative Tools -> Task Scheduler.
    #In Task Scheduler, expand the Task Scheduler tree to go to Task Scheduler Library -> Microsoft -> Windows -> UpdateOrchestrator.
    #Right click on Reboot task, and Disable it.
    #Disable Reboot Task
    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\UpdateOrchestrator" -TaskName "Reboot"

    #Open File Explorer, and navigate to the following folder:
    #C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator
    #rename the file called “Reboot” (no extension) to another name, such as Reboot.bak
    Rename-Item -Path "C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot" -NewName "Reboot.old" 

    #in order to prevent a task with the same name from being created again, create a new folder and name it “Reboot” 
    New-Item -Path "C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator" -ItemType "directory" -Name "Reboot"

    #Deny system to have permissions on reboot file
    $acl = get-acl -Path "C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot.old"
    $accessRestriction = New-Object  system.security.accesscontrol.filesystemaccessrule("System","FullControl","Deny")
    $Acl.SetAccessRule($accessRestriction)
    Set-Acl "C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot.old" $acl
    
    #WSUS Configuration
    $wsusServer = "HTTP://10.116.69.96:8530"
    set-ItemProperty -path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name UseWUServer -Value 1
    set-ItemProperty -path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name WUServer -Value $wsusServer
    set-ItemProperty -path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name WUStatusServer -Value $wsusServer 
}





