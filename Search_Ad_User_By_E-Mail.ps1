

cls


Do
{
    $command = ""

    $separator = ", `r`n"
    $option = [System.StringSplitOptions]::RemoveEmptyEntries
    [string[]]$folderPath = $null
    $counter = 0


    $readUsersEMail = Read-Host "Enter User(s) E-Mail or SamAccountName"
    [string[]]$readUsersEMail = $readUsersEMail.Split( $separator, $option)
    $group = Read-Host "Enter User(s) GroupName or ('n' for skip group membership) / (blank for all Groups!) "
    
    
        foreach($mail in $readUsersEMail)
        {
          if($mail.Contains("@"))
          {
            $user = Get-ADUser -Filter {EmailAddress -eq $mail} -Properties name, SamAccountName, MemberOf | select Name, SamAccountName, MemberOf
            $userData = $user.Name  + "`t EUA\" + $user.SamAccountName
            $userData

            if($group -eq "n")
            {
              continue;
            }
            elseif($group -ne "")
            {
            $groupName = $user.memberof | % { (Get-ADGroup $_).Name } | Where {$_ -like "*$group*" }
              if($groupName)
              {
                Write-Host "Is member of: $groupName" -BackgroundColor Green
              }
              else
              {
                 Write-Host "Is NOT member of: $group" -BackgroundColor Red
              }
            }
            elseif($group -eq "")
            {
              $groupName = $user.memberof | % { (Get-ADGroup $_).Name }
              [string[]]$addsf = ($user.memberof | % {(Get-ADGroup $_).DistinguishedName}).split(',')
              
             for($i=0; $i -lt $addsf.Length; $i++)
             {
                if(($addsf[$i] -like "*DC=*") )
                {
                    continue
                }
                else
                {
                    if($addsf[$i] -like "*CN=*")
                    {
                        $startIndex = $i+1
                        for($j = $startIndex; )
                        {
                            $folderPath += $addsf[$j]
                            $j++;
                            
                            if($addsf[$j]  -like "*DC=*")
                            {
                                for($k=$folderPath.Length - 1 ; $k -ge 0; $k--)
                                {
                                    $path+= $folderPath[$k].Trim("OU=") + "\"
                                }
                                
                                $groupName[$counter] + '            ' + $path.TrimEnd("\")
                                $counter++
                                $path = $null
                                $folderPath = $null
                                break;
                            }
                        }
                    }
                    
                }
             } 
            }
          }
          
          elseif( !$mail.Contains("@"))
          {
             
             if($mail.StartsWith("EUA\"))
             {
                $mail = $mail.Split("\")[1]
                SearchForAD_User $mail
             }
             else
             {
                SearchForAD_User $mail
             }
            
             
          }  

          else
          {
            Write-Host "Invalid E-Mail or SamAccountName!"
            break;
          }
        }
    
    
    Write-Host "Do you want to continue (y/n) " -BackgroundColor Green
    $command = Read-Host 
} While ($command –eq ‘y’)



Function SearchForAD_User
{
    param($mail)

    $user = Get-ADUser -Filter "SamAccountName -eq '$mail'" -Properties EmailAddress, SamAccountName, MemberOf `
                        | select EmailAddress, SamAccountName, MemberOf

                 $userData = $user.SamAccountName  + "`t" + $user.EmailAddress

                if(($userData -ne "`t") -or ($userData -ne $null))
                {
                    $userData
                }

                if($group -eq "n")
                {
                  break;
                }
                elseif($group -ne "")
                {
                  $user.memberof | % { (Get-ADGroup $_).Name } | Where {$_ -like "*$group*" }
                }
                elseif($group -eq "")
                {
                  $user.memberof | % { (Get-ADGroup $_).Name }
                }

                else
                {
                    Write-Host "No Such User !" -BackgroundColor Red
                }

}


