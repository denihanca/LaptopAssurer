<#********************************************Description********************************************

This script is an example of how to set OA functions for multiple OA-Servers at the same time by 
importing cmdlet parameter values from a CSV file, and finally gather and report the different
setting results returned from OA.

You can use other HPOACmdlets by changing the cmdlet name and you can customize your own CSV file 
with the same format as Input1.csv as below

***************************************************************************************************#>

<#CSV input file(Input1.csv):
OA,Username,Password
192.168.1.1,user1,password1
192.168.1.2,user2,password2
192.168.1.3,user3,password3
#>
$path = ".\Input1.csv"
$csv = Import-Csv $path
$connection = $csv | Connect-HPOA
try{
    $rt = $connection | Set-HPOAEBIPA -IP 192.168.1.10 -Target Interconnect -Netmask 255.255.255.0
    if($rt -ne $null)
    {
        foreach ($oareturn in $rt) 
        {
            $type = 0
            if($oareturn.StatusType -eq "Warning")
            {
                $type = 1
                $IP = $oareturn.IP
                $Message = $oareturn.StatusMessage
            }
            elseif($oareturn.StatusType -eq "Error")
            {
                $type = 2
                $IP = $oareturn.IP
                $Message = $oareturn.StatusMessage
            }
            switch($type)
            {
                #OK status is not returned in a Set cmdlet, ok is assumed if no result is returned.
                #However, you can get a warning or error
                1 { Write-Host "I have been warned by $IP : $Message" -ForegroundColor Yellow}
                2 { Write-Host "Something bad returned by $IP : $Message" -ForegroundColor Red}
                default {Write-Host "Success returned by $IP : $Message" -ForegroundColor Green}
            }
        }
    }
    $rt = $connection | Get-HPOAEBIPA
    $rt | Format-List
}
catch{
    $connection | Disconnect-HPOA
    exit
}