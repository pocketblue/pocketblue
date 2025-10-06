### Install Fedora Atomic on oneplus 6/6t

- **your current os and all your files will be deleted**
- installation process is the same for oneplus6 and oneplus6t, both devices are supported and tested
- before flashing pocketblue it is recommended to flash the stock rom and check every functionality
- you should have `fastboot` installed on your computer
- download image from [releases](https://github.com/pocketblue/pocketblue/releases/latest)
- unarchive it
- boot into fastboot and connect your phone to your computer via usb
- make sure bootloader is unlocked
- if your computer runs linux, and your device is oneplus 6, run `flash-oneplus6-enchilada.sh` script
- if your computer runs windows, and your device is oneplus 6, run `flash-oneplus6-enchilada.cmd` script
- if your computer runs linux, and your device is oneplus 6t, run `flash-oneplus6t-fajita.sh` script
- if your computer runs windows, and your device is oneplus 6t, run `flash-oneplus6t-fajita.cmd` script
- reboot and enjoy fedora

### Usage

- default username: `user`
- default password: `123456`
- [how to upgrade system and install packages](installing-packages.md)

### Rebasing to other desktops

- rebasing is a best way to try a new desktop
- before rebasing you should run `rpm-ostree reset`
- `sudo bootc switch quay.io/pocketblue/oneplus-sdm845-gnome-mobile:42` - recommended image for oneplus 6/6t
- `sudo bootc switch quay.io/pocketblue/oneplus-sdm845-gnome-desktop:42`
- `sudo bootc switch quay.io/pocketblue/oneplus-sdm845-plasma-mobile:42`
- `sudo bootc switch quay.io/pocketblue/oneplus-sdm845-plasma-desktop:42`
- `sudo bootc switch quay.io/pocketblue/oneplus-sdm845-phosh:42`

### Known bugs

- toolobx and distrobox don't work due to a bug in linux 6.15
- feel free to open issue and report any other bugs you find

### Unbricking using python3-edl

- [oneplus 6](https://github.com/pocketblue/oneplus6-unbrick)
- oneplus 6t: TODO

### Files used by the installation script, license info, source links

- `root.raw` - root partition for fedora, built by `.github/workflows/images.yml`
- `boot.raw` - /boot partition, built by `.github/workflows/images.yml`
- `efi.raw` - /boot/efi partition, built by `.github/workflows/images.yml`
- `uboot-enchilada.img` - oneplus 6 u-boot image, gpl2 license, [source](https://github.com/fedora-remix-mobility/u-boot)
- `uboot-fajita.img` - oneplus 6t u-boot image, gpl2 license, [source](https://github.com/fedora-remix-mobility/u-boot)

### Enabled copr repositories

- `pocketblue/common` - [copr](https://copr.fedorainfracloud.org/coprs/pocketblue/common) / [github](https://github.com/pocketblue/common-rpms)
- `pocketblue/sdm845` - [copr](https://copr.fedorainfracloud.org/coprs/pocketblue/sdm845) / [github](https://github.com/fedora-remix-mobility/packages)
- `@mobility/gnome-mobile` - [copr](https://copr.fedorainfracloud.org/coprs/g/mobility/gnome-mobile)
- [kernel source code](https://github.com/fedora-remix-mobility/sdm845-kernel)
