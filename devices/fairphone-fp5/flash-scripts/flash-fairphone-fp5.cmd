@echo on
setlocal EnableDelayedExpansion

echo Waiting for device to appear in fastboot...
fastboot getvar product 2>&1 | findstr /i "fp5"
if errorlevel 1 (
    echo Device not found or not a Fairphone 5
    pause
    exit /b 1
)

echo Erasing dtbo partitions...
fastboot erase dtbo --slot=all
if errorlevel 1 goto :error

echo Flashing vbmeta to disable verified boot...
fastboot flash vbmeta images\vbmeta-disabled.img --slot=all
if errorlevel 1 goto :error

echo Flashing u-boot to both boot slots...
fastboot flash boot images\u-boot.img --slot=all
if errorlevel 1 goto :error

echo Flashing ESP partition...
fastboot flash rawdump images\fedora_esp.raw
if errorlevel 1 goto :error

echo Flashing boot partition...
fastboot flash logdump images\fedora_boot.raw
if errorlevel 1 goto :error

echo Flashing root filesystem...
fastboot flash userdata images\fedora_rootfs.raw
if errorlevel 1 goto :error

echo Done flashing, rebooting now...
fastboot reboot

echo.
echo Flashing complete!
pause
exit /b 0

:error
echo.
echo An error occurred during flashing!
pause
exit /b 1
