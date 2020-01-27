
$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match "remote" 
}

if($app -eq $undefinedVariable)
{
    Write-Host "Progrm not Installed" -BackgroundColor Red
}
else{
    Write-Host "Progrm Installed" -BackgroundColor Green
}