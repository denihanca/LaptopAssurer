<#********************************************Description********************************************

This script is an example of how to get all the OA logs generated on a fixed date, such as 11/12/2014

***************************************************************************************************#>

<#CSV input file(Input3.csv):
OA,Username,Password
192.168.1.9,user1,pwd1
192.168.1.14,user2,pwd2
#>

$StartTime = "11/12/2014 0:00:00 AM"
$EndTime = "11/13/2014 0:00:00 AM"
$path = ".\input3.csv"
$csv = Import-Csv $path
$connection = $csv | Connect-HPOA
$rt = $connection | Get-HPOASysLog -Target OA
$logCount = 0
foreach ($oa in $rt) 
{
    $oaip=$oa.IP
    foreach($log in $oa.log)
    {
      if($log.Time -ge $StartTime -and $log.Time -le $EndTime)
      {
         $log.Time.ToString()+":"+$log.Message +"`n"
         $logCount++
      }
    }
    if($logCount -gt 0)
    {
         Write-Host "$oaip : There are $logCount logs found in that time." -ForegroundColor Green
         $logCount = 0
    }
    else
    {
         Write-Host "$oaip : No any logs found in that time." -ForegroundColor Yellow
    }
}
$connection | Disconnect-HPOA