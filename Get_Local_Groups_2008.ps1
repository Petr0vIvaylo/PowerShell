[string[]]$fullgroupNames = Get-WMIObject  -Class Win32_Group -Filter "LocalAccount=True" | Select -Property Name
foreach($gr in $fullgroupNames)
{
    $currentGr = $gr.trim("{@Name=}")
    $LocalGroup =[ADSI]"WinNT://Localhost/$currentGr"
     $UserNames = @($LocalGroup.psbase.Invoke("Members"))
     $currentGr
     $UserNames | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
     Write-Host "`n"

}



