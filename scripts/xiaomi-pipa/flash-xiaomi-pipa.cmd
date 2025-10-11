@echo on
setlocal EnableExtensions EnableDelayedExpansion

where fastboot || (pause & exit)

echo 'waiting for device appear in fastboot'

fastboot getvar product 2>&1 | findstr /i pipa || (pause & exit)
fastboot erase dtbo_ab || (pause & exit)
fastboot flash vbmeta_ab images/vbmeta-disabled.img || (pause & exit)
fastboot flash   boot_ab images/kxboot.img || (pause & exit)
fastboot flash      cust images/fedora_esp.raw || (pause & exit)
fastboot flash     super images/fedora_boot.raw || (pause & exit)
fastboot flash  userdata images/fedora_rootfs.raw || (pause & exit)

echo 'done flashing, rebooting device now'
fastboot reboot
pause
