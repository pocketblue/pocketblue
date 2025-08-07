### install fedora atomic on oneplus6 / oneplus6t

- **your current os and all your files will be deleted**
- installation process is similar for oneplus6 and oneplus6t, both devices supported and tested
- before flashing pocketblue we recommend you to flash stock rom first, then flash pocketblue on top of stock rom
- you should have `bash` and `fastboot` installed on your computer
- download latest `pocketblue-oneplus6-gnome-mobile-42.zip` [from here](https://github.com/onesaladleaf/pocketblue/actions/workflows/images-mipad5.yml)
- you can download it only if you are logged into your github account
- unarchive it
- boot into fastboot and connect your phone to your computer via usb
- make sure bootloader is unlocked
- for oneplus6 run `bash flash_oneplus6_enchilada.sh`
- for oneplus6t run `bash flash_oneplus6t_fajita.sh`
- reboot and enjoy fedora

### usage

- default username: `user`
- default password: `123456`
- to upgrade system use `bootc upgrade` or `rpm-ostree upgrade`
- after upgrade you should use `sudo ostree admin finalize-staged` to apply ugrade
- this needed because shutdown process is broken, instead of cleanly stop all systemd services it causes hard reboot or crash

### known bugs

- no sound
- toolobx and distrobox not work due to 6.15 kernel bug
- shutdown process is broken
- feel free to open issue and report any other bugs you find

### uninstall fedora and get stock rom back using fastboot

- https://wiki.lineageos.org/devices/enchilada/fw_update/
- https://wiki.lineageos.org/devices/fajita/fw_update/
- TODO: make ready to flash image and flashing scripts

### unbricking using python3-edl

- https://github.com/gmankab/guides/blob/main/unbrick/oneplus6.md
- TODO: create repository, add more docs for this

### files used by install script, license info, source links

- `root.raw` - root partition for fedora, built by `.github/workflows/images-oneplus6.yml`
- `boot.raw` - /boot partition, built by `.github/workflows/images-oneplus6.yml`
- `efi.raw` - /boot/efi partition, built by `.github/workflows/images-oneplus6.yml`
- `uboot-enchilada.img` - oneplus6 uboot image, gpl2 license, [source](https://github.com/fedora-remix-mobility/u-boot)
- `uboot-fajita.img` - oneplus6t uboot image, gpl2 license, [source](https://github.com/fedora-remix-mobility/u-boot)

### enabled copr repositories

- [@mobility/common](https://copr.fedorainfracloud.org/coprs/g/mobility/common) - [source](https://github.com/fedora-remix-mobility/packages)
- [onesaladleaf/pocketblue](https://copr.fedorainfracloud.org/coprs/onesaladleaf/pocketblue) - [source](https://github.com/onesaladleaf/pocketblue-rpms)
- [onesaladleaf/sdm845](https://copr.fedorainfracloud.org/coprs/onesaladleaf/sdm845) - [forked from](https://copr.fedorainfracloud.org/coprs/g/mobility/sdm845), [source](https://github.com/fedora-remix-mobility/packages), [kernel source](https://github.com/fedora-remix-mobility/sdm845-kernel)
- [@mobility/gnome-mobile](https://copr.fedorainfracloud.org/coprs/g/mobility/gnome-mobile) - only enabled in `quay.io/pocketblue/oneplus6-gnome-mobile` image
