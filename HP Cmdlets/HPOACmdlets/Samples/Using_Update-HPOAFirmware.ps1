<#********************************************Description********************************************

This script is an example of how to update OA firmware

***************************************************************************************************#>
##example 1: Update OA firmware with OA bin files from a URL.

#Step 1: Find the OA servers with firmware other then the specified version.
$oa = Find-HPOA 192.168.242.63-64 -Verbose |
where {$_.Firmware -ne "4.30"} |
% {Add-Member -PassThru -InputObject $_ Username "username"}|
% {Add-Member -PassThru -InputObject $_ Password "password"}

$oa | Format-List

#Step 2: Connect to the OAs
$c = $oa | Connect-HPOA 

#Step 3: Update OA firmware with the specified bin file.
Update-HPOAFirmware -Connection $c -Source URL -URL ftp://192.168.243.56/OA_FWBin/hpoa430.bin -AllowDowngrade | Format-List

#Step 4: Show the current OA firmware version again.
sleep -Seconds 30
$oa = Find-HPOA 192.168.242.63-64 -Verbose |
where {$_.Firmware -eq "4.30"}
$oa | Format-List

#Step 5: Disconnect the connections.
$c | Disconnect-HPOA -Connection $conn


##example 2: Update OA firmware with OA bin files from USB key.

#Step 1: Connect to the server with OA firmware bin file in USB key.
$c = Connect-HPOA 192.168.1.1 -Username "username" -Password "password"

#Step 2: Display the current firmware version.
$currentFWVersion = $(Find-HPOA 192.168.1.1).Firmware
Write-Host "The Firmware version before update is $currentFWVersion"

#Step 3: Update OA firmware with OA bin files from USB key.
$url = $(Get-HPOAUSBKey -Connection $c).FirmwareImageFiles.FileName
Update-HPOAFirmware -Connection $c -Source URL -URL $url -AllowDowngrade | fl

#Step 4: Display the firmware version after updating.
Sleep -Seconds 30
$currentFWVersion = $(Find-HPOA 192.168.1.1).Firmware
Write-Host "The Firmware version After update is $currentFWVersion"

#Step 5: Disconnect the connection.
Disconnect-HPOA -Connection $c




##example 3: Update OA firmware with OA iso files from a URL.
#Step 1: Show the current OA version
$oa = Find-HPOA 192.168.1.1-10 -Verbose |
% {Add-Member -PassThru -InputObject $_ Username "username"}|
% {Add-Member -PassThru -InputObject $_ Password "password"}

$oa | Format-List

#Step 2: Connect to the OAs
$c = $oa | Connect-HPOA 

#Step 3: Enable HP OA Firmware Management.
Set-HPOAFWManagement -Connection $c -State Enable -URL http://192.168.243.56/OA_FWISO/FW1000.2011_0906.51.iso

#Step 4: Update OAs firmware with the firmware iso file.
Update-HPOAFirmware -Connection $c -Source FW_ISO | Format-List

#Step 5: Show the OA version again.
Sleep -Seconds 30
Find-HPOA 192.168.1.1-10 -Verbose |Format-List

#Step 6: Disconnect the connections.
Disconnect-HPOA -Connection $c
