@echo off

where fastboot
if errorlevel 1 exit /b 1

echo waiting for device to appear in fastboot

fastboot getvar product 2>&1 | findstr /i fp5
if errorlevel 1 exit /b 1

fastboot erase dtbo
if errorlevel 1 exit /b 1

fastboot erase vendor_boot
if errorlevel 1 exit /b 1

rem fastboot flash vbmeta images\vbmeta-disabled.img
rem if errorlevel 1 exit /b 1

fastboot flash boot images\u-boot.img --slot=all
if errorlevel 1 exit /b 1

fastboot flash logdump images\fedora_esp.raw -S 256M
if errorlevel 1 exit /b 1

fastboot flash rawdump images\fedora_boot.raw -S 256M
if errorlevel 1 exit /b 1

fastboot flash userdata images\fedora_rootfs.raw -S 256M
if errorlevel 1 exit /b 1

echo done flashing, rebooting now
fastboot reboot
