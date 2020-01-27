$resourseServersList = Import-Csv "path" 
$xl = New-Object -COM "Excel.Application"
$xl.Visible = $true
$wb = $xl.Workbooks.Open("path")
$ws = $wb.Sheets.Item(1)

$rows = $ws.UsedRange.Rows.Count

$ipColumn = $ws.Range("E3", "E$rows").Value()
$fqdnColumn = $ws.Range("F3", "F$rows").Value()


[datetime]$start = "01-Jan-19"
[datetime]$end = "31-Dec-19"

$Session = New-Object -ComObject "Microsoft.Update.Session"
$Searcher = $Session.CreateUpdateSearcher() 
$historyCount = $Searcher.GetTotalHistoryCount()
$serverKB = $Searcher.QueryHistory(0, $historyCount) | Where-Object{$_.Title -like "*KB*" } | Where-Object {(($_.Date -ge $start) -and ($_.Date -le $end))}| Select-Object  Title, Date | Sort-Object -Property date    

$result = [ordered]@{}

foreach($line in $serverKB)
{
    $currentLine = $line.Title.ToString()
    #$currentLine = [regex]::match($currentLine , "[(KB\d)]*$").Groups[0].Value
    if(($currentLine -ne "") -or ($currentLine -eq $null))
    {
        if($result[$currentLine])
        {
            Continue
        }
        else
        {
            $result.Add($currentLine, $line.Date)
        }
        
    }
    
}
    
$result | ft -AutoSize




