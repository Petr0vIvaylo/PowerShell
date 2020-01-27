$printerData = Import-Csv "path" 
$printers_A_Record = [ordered]@{}
$xl = New-Object -COM "Excel.Application"
$xl.Visible = $true
$wb = $xl.Workbooks.Open("path")
$ws = $wb.Sheets.Item(1)

$rows = $ws.UsedRange.Rows.Count

$ipColumn = $ws.Range("E3", "E$rows").Value()
$fqdnColumn = $ws.Range("F3", "F$rows").Value()




New-Item -Path "path" -Name "Mail-A-Records.txt" -ItemType "file" 

if($ipColumn.Length -ne $fqdnColumn.Length)
{
    Write-Host {"IP column not equal to FDN column" }
    exit
}
else
{
    for($i=0; $i -le $ipColumn.Length -1; $i++ )
    {
        $firstLine = "Add Record(FQDN): " + $fqdnColumn[$i,1]
        $secondLine = "IP Address: " + $ipColumn[$i,1]
        Add-Content -Path "path" -Value $firstLine
        Add-Content -Path "path" -Value $secondLine
        Write-Output "`n" | Out-File "path" -encoding ASCII -append
    }
}
        

$wb.Close()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl)