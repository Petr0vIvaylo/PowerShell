$localGroups = Get-LocalGroup
$result = [ordered]@{}


foreach($group in $localGroups)
{
    [string[]]$groupMembers = Get-LocalGroupMember -Name $group 
    
    if(($groupMembers -ne "") -or ($groupMembers -ne $null))
    {
        $result.add($group, $groupMembers)
    }
    else
    {
        Continue
    }
}

foreach($kvp in $result.Keys)
{
    
    if($result[$kvp])
    {
        "Group: "+$kvp
        foreach($var in $result[$kvp])
        {
            $var
        }
        
        write-host "`n"
    }
}