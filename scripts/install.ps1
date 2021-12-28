# No shebang, as Windows only
<#
.SYNOPSIS 
    Installs Apple US International Keyboard layout for Windows
 
.DESCRIPTION 
    Downloads and installes latest release from https://github.com/repos/geekzter/mac-us-international-keyboard-windows
#> 
param ( 
    [parameter(Mandatory=$false)][switch]$SkipIfInstalled=$false
) 

# Validation
if (($PSVersionTable.PSEdition -ieq "Core") -and !$IsWindows) {
    Write-Output "Not running on Windows, exiting"
    exit
}    
if ($SkipIfInstalled -and ((Get-ChildItem -Path "HKLM:\SYSTEM\ControlSet001\Control\Keyboard Layouts" | Get-ItemProperty | Select-Object -ExpandProperty "Layout File") -icontains "USIAPPLE.dll")) {
    Write-Host "Keyboard layout already installed, exiting"
    exit
}

$keyboardLayountResponse = (Invoke-RestMethod -Uri https://api.github.com/repos/geekzter/mac-us-international-keyboard-windows/releases/latest)
if (!$keyboardLayountResponse.assets.browser_download_url) {
    Write-Warning "Package download not found"
    exit
}

# Install Apple US International keyboard layout
Invoke-Webrequest -Uri $keyboardLayountResponse.assets.browser_download_url -OutFile $env:USERPROFILE\Downloads\keyboardLayout.zip -UseBasicParsing 
New-Item -ItemType Directory -Path (Join-Path $([System.IO.Path]::GetTempPath()) $([System.Guid]::NewGuid())) | Select-Object -ExpandProperty FullName | Set-Variable keyboardExtractDirectory
Expand-Archive -Path $env:USERPROFILE\Downloads\keyboardLayout.zip -DestinationPath $keyboardExtractDirectory
$keyboardSetupDirectory = Join-Path $keyboardExtractDirectory $($keyboardLayountResponse.assets.name -replace ".zip","")
Invoke-Item $keyboardSetupDirectory\setup.exe
