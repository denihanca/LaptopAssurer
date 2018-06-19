<#********************************************Description********************************************

This script is an example of how to update iLO firmware in enclosure

***************************************************************************************************#>

#Step 1: Use Find-HPOA to find all the OAs with firmware later then v4.00
$c = Find-HPOA 192.168.242.60-70 -Verbose |
where {$_.Firmware.StartsWith("4.")} |
% {Add-Member -PassThru -InputObject $_ Username "username"}|
% {Add-Member -PassThru -InputObject $_ Password "password"}|
Connect-HPOA 

#Step 2: Use Get-HPOAFWSummary to get all the firmware information within the Enclosure.
#The cmdlet is supported with OA firmware v4.00 and later.
$firm = Get-HPOAFWSummary $c

for($i = 0; $i -lt $firm.Count; $i++)
{
    #Then desplay all the information one by one.
    Write-Host "#Firmware information for $($firm[$i].IP) $($firm[$i].Hostname)#" -ForegroundColor Green

    Write-Host "## OA Firmware Information ##" -ForegroundColor DarkGreen
    $firm[$i].OnboardAdministratorFirmwareInformation | Format-Table

    Write-Host "## Device Firmware Information ##" -ForegroundColor DarkGreen
    $ilo3baystring = $null
    $ilo4baystring = $null
    foreach($d in $firm[$i].DeviceFirmwareInformation)
    {
        Write-Host "Bay $($d.Bay)"
        $d.DeviceFWDetail| Format-Table
        Write-Host "`n"
        if($d.DeviceFWDetail.FirmwareComponent.Contains("iLO3"))    
        {
            if($ilo3baystring -eq $null)
            {
                $ilo3baystring = "" + $d.Bay
            }
            else
            {
                $ilo3baystring = $ilo3baystring + "," + $d.Bay
            }
        }
        elseif($d.DeviceFWDetail.FirmwareComponent.Contains("iLO4"))
        {
            if($ilo4baystring -eq $null)
            {
                $ilo4baystring = "" + $d.Bay
            }
            else
            {
                $ilo4baystring = $ilo4baystring + "," + $d.Bay
            }
        }
    }

    #Step 3: Update ilo firmware with the specified iLO firmware bin files.
    #iLO3 and iLO4 firmware need to be updated seperately. 
    #Update-HPOAiLO is valid only for ProLiant SERVER blades.
    if($ilo3baystring -ne $null)
    {
        Update-HPOAiLO -Connection $c[$i] -Bay $ilo3baystring -URL ftp://192.168.243.56/ILO_FWBin/ilo3_170_p12.bin -Verbose 
    }

    if($ilo4baystring -ne $null)
    {
        Update-HPOAiLO -Connection $c[$i] -Bay $ilo4baystring -url ftp://192.168.243.56/ILO_FWBin/ilo4_132.bin -Verbose
    }
}


#Step 4: Disconnect the connections.
Disconnect-HPOA $c