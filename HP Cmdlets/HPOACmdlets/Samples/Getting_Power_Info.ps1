<#********************************************Description********************************************

This script is an example of how to get OA power configurations

***************************************************************************************************#>
$con = Connect-HPOA -OA 192.168.242.63 -Username username -Password password
Get-HPOAPower $con
Disconnect-HPOA $con