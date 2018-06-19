<#********************************************Description********************************************

This script is an example of how to use Invoke-HPOAiLOCommand to get or set the iLO configurations
for iLO servers inside the target OA. The scripts shows how to change iLO password for iLOs in all 
bays in the OA when the current password does not work.

***************************************************************************************************#>

#Step1: Get the value of ExternalCommand parameter by executing HPiLO Cmdlet.If you want to use this cmdlet, you must install iLO 1.2 version or later in your system.
#This command will be sent to the iLOs inside the enclosure managed by the OA.
#The parameters Server, Username and Password are needed by the iLO cmdlets to run correctly, but are not needed for the target iLOs.  
#The recommended practice is to use the values for the target OA.  This will give the expected results.
#The only real required validation done is on the connection to the OAs.
$command = Set-HPiLOPassword -Server 192.168.1.1 -Username $username -Password $password -NewPassword $Newpassword -OutputType ExternalCommand

#Step2: Use "Find-HPOA" to find available OAs and execute the Invoke-HPOAiLOCommand on those OAs
#Note: Make sure both Username and password are correct.
$available_OAs = Find-HPOA 192.168.1.62-64 -Verbose
if($available_OAs.count -eq 0)
{
   Write-Host "No available OA server found." -ForegroundColor Red
}
else
{
$available_OAs |
% {Add-Member -PassThru -InputObject $_ Username "$Username"}|
% {Add-Member -PassThru -InputObject $_ Password "$Password"}|
Connect-HPOA | Invoke-HPOAiLOCommand -iLOCommand $command -Bay All 
}
$available_OAs | Disconnect-HPOA
