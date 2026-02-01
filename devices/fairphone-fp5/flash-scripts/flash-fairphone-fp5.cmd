@echo off
setlocal EnableDelayedExpansion

echo Waiting for device to appear in fastboot...
fastboot getvar product 2>&1 | findstr /i "fp5"
if errorlevel 1 (
    echo Device not found or not a Fairphone 5
    pause
    exit /b 1
)

echo.
echo Checking image sizes against partition sizes...
echo.

call :check_image_size logdump images\fedora_esp.raw
if errorlevel 1 goto :error

call :check_image_size rawdump images\fedora_boot.raw
if errorlevel 1 goto :error

call :check_image_size userdata images\fedora_rootfs.raw
if errorlevel 1 goto :error

echo.
echo All image size checks passed, proceeding with flash...
echo.

echo Erasing dtbo partitions...
fastboot erase dtbo
if errorlevel 1 goto :error

echo Erasing vendor_boot partitions...
fastboot erase vendor_boot
if errorlevel 1 goto :error

rem echo Flashing vbmeta to disable verified boot...
rem fastboot flash vbmeta images\vbmeta-disabled.img
rem if errorlevel 1 goto :error

echo Flashing u-boot to both boot slots...
fastboot flash boot images\u-boot.img --slot=all
if errorlevel 1 goto :error

echo Flashing ESP partition...
call :flash_image logdump images\fedora_esp.raw
if errorlevel 1 goto :error

echo Flashing boot partition...
call :flash_image rawdump images\fedora_boot.raw
if errorlevel 1 goto :error

echo Flashing root filesystem (this may take a while)...
call :flash_image userdata images\fedora_rootfs.raw
if errorlevel 1 goto :error

echo Done flashing, rebooting now...
timeout /t 10
fastboot reboot

echo.
echo Flashing complete!
pause
exit /b 0

:check_image_size
setlocal
set "partition=%~1"
set "image=%~2"

if not exist "%image%" (
    echo ERROR: Image file not found: %image%
    exit /b 1
)

for %%A in ("%image%") do set "image_size=%%~zA"

for /f "tokens=2" %%a in ('fastboot getvar partition-size:%partition% 2^>^&1 ^| findstr /i "partition-size"') do set "partition_size_hex=%%a"

if not defined partition_size_hex (
    echo WARNING: Could not get partition size for %partition%, skipping size check
    exit /b 0
)

set /a "partition_size=%partition_size_hex%"

echo Partition %partition% size: %partition_size% bytes
echo Image %image% size: %image_size% bytes

if %image_size% gtr %partition_size% (
    echo ERROR: Image %image% ^(%image_size% bytes^) is larger than partition %partition% ^(%partition_size% bytes^)
    exit /b 1
)

set /a "free_mb=(%partition_size% - %image_size%) / 1024 / 1024"
echo OK: Image fits in partition ^(%free_mb% MB free^)
echo.
endlocal
exit /b 0

:flash_image
setlocal
set "partition=%~1"
set "image=%~2"

fastboot flash %partition% "%image%"
endlocal
exit /b %errorlevel%

:error
echo.
echo An error occurred during flashing!
pause
exit /b 1
