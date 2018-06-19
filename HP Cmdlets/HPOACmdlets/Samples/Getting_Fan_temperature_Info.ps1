<#********************************************Description********************************************

This script is an example of how to get the details of Enclosure fans and temperatures

***************************************************************************************************#>

$con = Connect-HPOA -OA 192.168.242.63 -Username username -Password password
$f = Get-HPOAEnclosureFan $con -Fan All
$t = Get-HPOAEnclosureTemp $con
$f.Fan  | Select-Object -Property FanNumber, Status, Speed, SparePartNumber | Format-Table
$t.EnclosureTemp | Format-Table
Disconnect-HPOA $con