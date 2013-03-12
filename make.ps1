if($args[0] -eq "clean"){
    rm src/maps/*.lua
    return
}elseif($args[0] -eq "reset"){
    rm src/maps/*.lua
    rm bin/
    return
}

Write-Host "Downloading love2d..."

$check = Test-Path -PathType Container bin
if($check -eq $false){
    New-Item 'bin' -type Directory
}

$webclient = New-Object System.Net.WebClient
$love = "bin\love-0.8.0-win-x86\love.exe"
$check = Test-Path $love

if($check -eq $false){
    $filename = "bin\love-0.8.0-win-x86.zip"

    $check = Test-Path $filename

    if($check -eq $false){
	Write-Host "Downloading love2d..."
        $url = "https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x86.zip"
        $webclient.DownloadFile($url,$filename)
    }

    $shell_app=new-object -com shell.application
    $zip_file = $shell_app.namespace((Get-Location).Path + "\$filename")
    $destination = $shell_app.namespace((Get-Location).Path + "\bin")
    $destination.Copyhere($zip_file.items())
}

$tmx = "bin\tmx2lua.exe"
$check = Test-Path $tmx

if($check -eq $false){

    $filename = "bin\tmx2lua.windows32.zip"

    $check = Test-Path $filename

    if($check -eq $false){
	Write-Host "Downloading tmx2lua..."
        $url = "http://hawkthorne.github.com/tmx2lua/downloads/tmx2lua.windows32.zip"
        $webclient.DownloadFile($url,$filename)
    }

    $shell_app=new-object -com shell.application
    $zip_file = $shell_app.namespace((Get-Location).Path + "\$filename")
    $destination = $shell_app.namespace((Get-Location).Path + "\bin")
    $destination.Copyhere($zip_file.items())
}

$fileEntries = [IO.Directory]::GetFiles("src\maps"); 
foreach($fileName in $fileEntries) 
{ 
    $lua = $filename.split(".")[0] + ".lua"
    $exists = Test-Path $lua
    $older = $true

    if($exists -eq $true) {
        $older = (Get-Item $filename).LastWriteTime -gt (Get-Item $lua).LastWriteTime
    } 

    if($older -eq $true) {
        .\bin\tmx2lua.exe $filename $lua
    }
} 

if($args[0] -eq "run"){
    Write-Host "Running Journey to the center of Hawkthorne..."
    .\bin\love-0.8.0-win-x86\love.exe src
}
