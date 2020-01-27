$computerName = $env:COMPUTERNAME

$uninstallKey = "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMashine', $computerName)
$regKey = $reg.OpenSubKey($uninstallKey)

$subKeys = $regKey.GetSubKeyNames()

foreach($key in $subKeys)
{
    $thisKey = $uninstallKey + "\\"+ $key
    $thisSubKey = $reg.OpenSubKey($thisKey)
    $displayName = $thisSubKey.GetValue("DisplayName")
    Write-Host $displayName
}