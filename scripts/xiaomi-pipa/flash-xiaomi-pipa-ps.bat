@(set "0=%~f0"^)#) & powershell -nop -c iex([io.file]::ReadAllText($env:0)) & exit /b
$ErrorActionPreference = "Stop"

trap {
  Write-Host $_.Exception.Message
  Read-Host
}

Get-Command fastboot

echo 'waiting for device appear in fastboot'

$ErrorActionPreference = "Continue"
if (-not (fastboot getvar product 2>&1 | Select-String pipa)) { throw 'wrong device' }
$ErrorActionPreference = "Stop"

fastboot erase dtbo_ab
fastboot flash vbmeta_ab images/vbmeta-disabled.img
fastboot flash   boot_ab images/kxboot.img
fastboot flash      cust images/fedora_esp.raw
fastboot flash     super images/fedora_boot.raw
fastboot flash  userdata images/fedora_rootfs.raw

echo 'done flashing, rebooting device now'
fastboot reboot
Read-Host
