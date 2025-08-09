### Install Fedora Atomic on oneplus6 / oneplus6t

- **your current os and all your files will be deleted**
- installation process is the same for oneplus6 and oneplus6t, both devices are supported and tested
- before flashing pocketblue it is recommended to flash the stock rom and check every functionality
- you should have `bash` and `fastboot` installed on your computer
- download one of the latest release archives [from here](https://github.com/onesaladleaf/pocketblue/actions/workflows/images-oneplus6.yml); you have to be logged into your github account
- unarchive it
- boot into fastboot and connect your phone to your computer via usb
- make sure bootloader is unlocked
- for oneplus6 run `bash flash_oneplus6_enchilada.sh`
- for oneplus6t run `bash flash_oneplus6t_fajita.sh`
- reboot and enjoy fedora

### Usage

- default username: `user`
- default password: `123456`
- to upgrade the system use `bootc upgrade` or `rpm-ostree upgrade`
- after that you should run `sudo ostree admin finalize-staged` to apply the ugrade
- this is required because the shutdown process is currently broken and may cause the system to freeze or crash

### Known bugs

- no sound
- toolobx and distrobox don't work due to a bug in linux 6.15
- shutdown process is broken
- feel free to open issue and report any other bugs you find

### Uninstall Fedora and get stock rom back using fastboot

- https://wiki.lineageos.org/devices/enchilada/fw_update/
- https://wiki.lineageos.org/devices/fajita/fw_update/
- TODO: make ready to flash images and flashing scripts

### Unbricking using python3-edl

- https://github.com/gmankab/guides/blob/main/unbrick/oneplus6.md
- TODO: create repository, add more docs

### Files used by the installation script, license info, source links

- `root.raw` - root partition for fedora, built by `.github/workflows/images-oneplus6.yml`
- `boot.raw` - /boot partition, built by `.github/workflows/images-oneplus6.yml`
- `efi.raw` - /boot/efi partition, built by `.github/workflows/images-oneplus6.yml`
- `uboot-enchilada.img` - oneplus6 u-boot image, gpl2 license, [source](https://github.com/fedora-remix-mobility/u-boot)
- `uboot-fajita.img` - oneplus6t u-boot image, gpl2 license, [source](https://github.com/fedora-remix-mobility/u-boot)

### Enabled copr repositories

- [@mobility/common](https://copr.fedorainfracloud.org/coprs/g/mobility/common) - [source](https://github.com/fedora-remix-mobility/packages)
- [onesaladleaf/pocketblue](https://copr.fedorainfracloud.org/coprs/onesaladleaf/pocketblue) - [source](https://github.com/onesaladleaf/pocketblue-rpms)
- [onesaladleaf/sdm845](https://copr.fedorainfracloud.org/coprs/onesaladleaf/sdm845) - [forked from](https://copr.fedorainfracloud.org/coprs/g/mobility/sdm845), [source](https://github.com/fedora-remix-mobility/packages), [kernel source](https://github.com/fedora-remix-mobility/sdm845-kernel)
- [@mobility/gnome-mobile](https://copr.fedorainfracloud.org/coprs/g/mobility/gnome-mobile) - only enabled in the `quay.io/pocketblue/oneplus6-gnome-mobile` image
