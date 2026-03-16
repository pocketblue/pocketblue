@echo on
setlocal EnableExtensions EnableDelayedExpansion

where adb      || (pause & exit)
where fastboot || (pause & exit)

echo 'waiting for device to appear in fastboot'
fastboot getvar product 2>&1 | findstr /i nabu      || (pause & exit)
fastboot erase dtbo_ab                              || (pause & exit)
fastboot flash vbmeta_ab images/vbmeta-disabled.img || (pause & exit)
fastboot flash dtbo_ab   images/dtbo.img            || (pause & exit)
fastboot flash boot_ab   images/twrp.img            || (pause & exit)
fastboot reboot                                     || (pause & exit)

echo 'waiting for device to appear in adb'
adb wait-for-recovery                                   || (pause & exit)
adb shell "getprop ro.product.device | grep nabu"       || (pause & exit)
adb shell "until twrp unmount /data ; do sleep 1; done" || (pause & exit)
adb push bin/sgdisk /bin/sgdisk                         || (pause & exit)
adb push bin/parted /bin/parted                         || (pause & exit)

@REM validating that the /dev/sda31 partition is userdata
adb shell "parted /dev/block/sda print | grep userdata | grep -qE '^31'" || (pause & exit)

adb shell sgdisk --resize-table 64 /dev/block/sda || (pause & exit)

@REM partitioning
adb shell "if [ -e /dev/block/sda35 ]; then umount /dev/block/sda35 || true; sgdisk --delete=35 /dev/block/sda; fi" || (pause & exit)
adb shell "if [ -e /dev/block/sda34 ]; then umount /dev/block/sda34 || true; sgdisk --delete=34 /dev/block/sda; fi" || (pause & exit)
adb shell "if [ -e /dev/block/sda33 ]; then umount /dev/block/sda33 || true; sgdisk --delete=33 /dev/block/sda; fi" || (pause & exit)
adb shell "if [ -e /dev/block/sda32 ]; then umount /dev/block/sda32 || true; sgdisk --delete=32 /dev/block/sda; fi" || (pause & exit)
adb shell "if [ -e /dev/block/sda31 ]; then umount /dev/block/sda31 || true; sgdisk --delete=31 /dev/block/sda; fi" || (pause & exit)
adb shell "parted -m /dev/block/sda print free | tail -1 | cut -d: -f2 | tee /tmp/start"                            || (pause & exit)
adb shell parted -s /dev/block/sda -- mkpart userdata    ext4  $(cat /tmp/start) -3GB                               || (pause & exit)
adb shell parted -s /dev/block/sda -- mkpart fedora_boot ext4  -3GB -1GB                                            || (pause & exit)
adb shell parted -s /dev/block/sda -- mkpart esp         fat32 -1GB 100%%                                           || (pause & exit)
adb shell parted -s /dev/block/sda -- set 33 esp on                                                                 || (pause & exit)

adb reboot bootloader

echo 'waiting for device to appear in fastboot'
fastboot getvar product 2>&1 | findstr /i nabu      || (pause & exit)
fastboot erase dtbo_ab                              || (pause & exit)
fastboot flash boot_ab     images/aloha.img         || (pause & exit)
fastboot flash esp         images/fedora_esp.raw    || (pause & exit)
fastboot flash fedora_boot images/fedora_boot.raw   || (pause & exit)
fastboot flash userdata    images/fedora_rootfs.raw || (pause & exit)

echo 'rebooting (this may take a while, DO NOT DISCONNECT THE DEVICE)'
fastboot reboot
pause
