<#********************************************Description********************************************

This script is an example of how to find the specific role types (Active, Standby, All) of OA servers 
within an IP Range.

***************************************************************************************************#>

#Example 1: Find available OA Servers that they are in active roles in a range of IP addresses.
Find-HPOA -Range 192.168.1.1-255 -Role Active
<#Warning : It might take a while to search for all the HP OAs if the input is a very large range. Use Verbose for more information.

IP           : 192.168.1.62
Hostname     : 11hp.chn.hp.com
ProductName  : c3000 Tray with embedded DDR2 Onboard Administrator
Firmware     : 3.11
Role         : ACTIVE
SerialNumber : PAMMT0C9VXA09J
UUID         : 18PAMMT0C9VXA09J

IP           : 192.168.1.63
Hostname     : 22hp.chn.hp.com
ProductName  : BladeSystem c7000 DDR2 Onboard Administrator with KVM
Firmware     : 4.30
Role         : ACTIVE
SerialNumber : OB93BP0215    
UUID         : 09OB93BP0215    

IP           : 192.168.1.64
Hostname     : 33hp.chn.hp.com
ProductName  : c3000 Tray with embedded DDR2 Onboard Administrator
Firmware     : 4.40
Role         : ACTIVE
SerialNumber : PAMMT0A9VWY01N
UUID         : 18PAMMT0A9VWY01N #>

#Example 2: Piping output from Find-HPOA to Connect-HPOA,Get-HPOAInfo
#Notes: Make sure both Username and password are correct!
$available_OAs = Find-HPOA 192.168.1.62-64 -Verbose
if($available_OAs.count -eq 0)
{
   Write-Host "No available OA server found." -ForegroundColor Red
}
else
{
$available_OAs |
% {Add-Member -PassThru -InputObject $_ Username "Administrator"}|
% {Add-Member -PassThru -InputObject $_ Password "Admin"}|
Connect-HPOA | Get-HPOAInfo -Verbose
}
$available_OAs | Disconnect-HPOA
<#Warning : It might take a while to search for all the HP OAs if the input is a very large range. Use Verbose for more information.
VERBOSE: Using 3 threads for search
VERBOSE: Pinging 192.168.1.62
VERBOSE: Pinging 192.168.1.63
VERBOSE: Pinging 192.168.1.64
VERBOSE: Using 3 threads

IP                   : 192.168.1.62
Hostname             : 11hp.chn.hp.com
StatusType           : OK
StatusMessage        : OK
OnboardAdministrator : {@{ProductName=c3000 Tray with embedded DDR2 Onboard Administrator; PartNumber=488099-B21; SparePartNo=486823-001; SerialNumber=PAMMT0C9VXA09J; UUID=18PAMMT0C9VXA09J; 
                       Manufacturer=HP; FirmwareVer=3.11 Aug 19 2010; HwBoardType=3; HwVersion=C0; Bay=2}}

IP                   : 192.168.1.63
Hostname             : 22hp.chn.hp.com
StatusType           : OK
StatusMessage        : OK
OnboardAdministrator : {@{ProductName=BladeSystem c7000 DDR2 Onboard Administrator with KVM; PartNumber=456204-B21; SparePartNo=503826-001; SerialNumber=OB93BP0215; UUID=09OB93BP0215; Manufacturer=HP; 
                       FirmwareVer=4.30 Jul 08 2014; HwBoardType=2; HwVersion=A2; LoaderVersion=U-Boot 1.2.0 (Feb 24 2009 - 09:45:33); SerialPort=; Bay=1}}

IP                   : 192.168.1.64
Hostname             : 33hp.chn.hp.com
StatusType           : OK
StatusMessage        : OK
OnboardAdministrator : {@{ProductName=c3000 Tray with embedded DDR2 Onboard Administrator; PartNumber=488099-B21; SparePartNo=486823-001; SerialNumber=PAMMT0A9VWY01N; UUID=18PAMMT0A9VWY01N; 
                       Manufacturer=HP; FirmwareVer=4.40 Oct 13 2014; HwBoardType=3; HwVersion=A0; LoaderVersion=U-Boot 1.2.0 (Dec  8 2008 - 15:14:50); SerialPort=; Bay=2}}#>