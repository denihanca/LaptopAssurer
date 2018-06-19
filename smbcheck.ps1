$computer = read-host -prompt "Input Computer Name"
$copt = Get-WmiObject -query "select * from Win32_OptionalFeature where name = 'SMB1PROTOCOL'" -computername $computer
if($copt.InstallState -eq 2){
	"- SMBv1 disabled > OK"}
else{
	"!!! SMBv1 enabled"
}
$copt.InstallState