<#********************************************Description********************************************

This script is an example of how to get server status in an enclosure

***************************************************************************************************#>

$con = Connect-HPOA -OA 192.168.242.63 -Username username -Password password
$ssta = Get-HPOAServerStatus -Bay All $con
$ssta.Blade | Select-Object -Property Bay, Power, CurrentWattageUsed, Health, UnitIdentificationLED, VirtualFan | Format-Table *
Disconnect-HPOA $con