#check to surabaya
$dts = gwmi win32_operatingsystem -computer sb-s-hyperv
$sbtime = $dts.converttodatetime($dts.localdatetime)
$idtime = get-date
$tdidsb = new-timespan -start $sbtime -end $idtime
if ($tdidsb.totalseconds -gt 600){
	msg console /server:id-l-bkurniawa6 "time diffirence between Surabaya server and Jakarta server is more than 10 minutes ($tdidsb.totalseconds). Please check Synchronisation status."
}else{
	msg console /server:id-l-bkurniawa6 "SB ok"
}

#check to Mataram
$dts = gwmi win32_operatingsystem -computer mt-s-hyperv
$sbtime = $dts.converttodatetime($dts.localdatetime)
$idtimet = get-date
$idtime = $idtimet.adddays(2)
$tdidsb = new-timespan -start $sbtime -end $idtime
if ($tdidsb.totalseconds -gt 600){
	msg console /server:id-l-bkurniawa6 "time diffirence between Mataram server and Jakarta server is more than 10 minutes ($tdidsb.totalseconds). Please check Synchronisation status."
}else{
	msg console /server:id-l-bkurniawa6 "MT ok"
}