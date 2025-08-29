@(set "0=%~f0"^)#) & powershell -nop -c iex([io.file]::ReadAllText($env:0)) & exit /b
$ErrorActionPreference = "Stop"

trap {
  Write-Host $_.Exception.Message
  Read-Host
}

Get-Command adb
Get-Command fastboot

echo 'waiting for device appear in fastboot'
$ErrorActionPreference = "Continue"
if (-not (fastboot getvar product 2>&1 | Select-String nabu)) { throw 'wrong device' }
$ErrorActionPreference = "Stop"
fastboot erase dtbo_ab
fastboot flash boot_ab     images/uboot.img

echo 'done flashing, rebooting now'
fastboot reboot
Read-Host
