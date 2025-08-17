# Fedora Atomic on OnePlus 6/6T

## Installation

> [!WARNING]
> Your current OS and all your files will be deleted, dualboot with Android is not supported yet.
> Software is provided AS IS, without warranty of any kind

### Prerequisites

Installation requires fastboot (`android-tools`)

Before installing Pocketblue, it is recommended to install the latest version of
stock OS to ensure all firmware is present on the vendor partitions.

Make sure the bootloader is unlocked,
download the latest Pocketblue release from [releases](https://github.com/pocketblue/pocketblue/releases/latest)
and extract the archive, then proceed to installation

### Automatic installation

Boot into fastboot, connect your phone to your computer via usb, and run the installation script:

- `./flash_oneplus6_enchilada.sh` for OnePlus 6
- `./flash_oneplus6t_fajita.sh` for OnePlus 6T

Your device will reboot and boot into Pocketblue automatically.

**DO NOT** reboot via the power button on the device: this can result in not all data being properly written to storage.

### Manual installation

Partition layout:

- `boot` - u-boot
- `system_a` - /boot partition (`images/boot.raw`)
- `system_b` - ESP (/boot/efi) (`images/esp.raw`)
- `userdata` - root partition (`images/root.raw`)

Boot into fastboot, connect your phone to your computer via usb, and install the system:

```bash
fastboot erase dtbo_a
fastboot erase dtbo_b

# replace <DEVICE> with enchilada for OnePlus 6 or fajita for OnePlus 6T
fastboot flash boot images/uboot_<DEVICE>.img --slot=all

fastboot flash system_a images/boot.raw
fastboot flash system_b images/esp.raw
fastboot flash userdata images/root.raw

# reboot the device, this may take a while
fastboot reboot
```

**DO NOT** reboot via the power button on the device: this can result in not all data being properly written to storage.

## Usage

### Default user

- username: `user`
- password: `123456`

### Upgrading the system
 
To upgrade the system use `bootc upgrade` or `rpm-ostree upgrade`

After that you **must** run `sudo ostree admin finalize-staged` to apply the upgrade.
This is required because the shutdown process is currently broken and may cause
the system to freeze or crash.

### Available images

There are multiple images with different desktops available

- `oneplus6-gnome-mobile` - \[recommended\] [Gnome Shell Mobile](https://gitlab.gnome.org/verdre/gnome-shell-mobile)
- `oneplus6-gnome-desktop` - Gnome Shell
- `oneplus6-phosh` - Phosh
- `oneplus6-plasma-mobile` - KDE Plasma Mobile
- `oneplus6-plasma-desktop` - KDE Plasma
- `oneplus6-base` - minimal base image without a desktop, probably not what you're looking for

You can rebase to a different image without reinstalling the system
(replace `IMAGE_NAME` with the desired image):

```bash
sudo rpm-ostree reset # this will remove all your layered rpm packages (!)
sudo bootc switch quay.io/pocketblue/IMAGE_NAME:42
sudo ostree admin finalize-staged
sudo reboot
```

## Known issues

- list of oneplus6 specific issues: [issues](https://github.com/pocketblue/pocketblue/issues?q=is%3Aissue%20state%3Aopen%20label%3Adevice%3Aoneplus6)
- all Pocketblue issues: [issues](https://github.com/pocketblue/pocketblue/issues)

Feel free to open new issues!

## Unbricking using python3-edl

- [OnePlus 6](https://github.com/pocketblue/oneplus6-unbrick)
- OnePlus 6T: TODO

### Files used by the installation script, license info, source links

- `root.raw` - root partition for fedora, built by `.github/workflows/images-oneplus6.yml`
- `boot.raw` - /boot partition, built by `.github/workflows/images-oneplus6.yml`
- `efi.raw` - /boot/efi partition, built by `.github/workflows/images-oneplus6.yml`
- `uboot-enchilada.img` - OnePlus 6 u-boot image, GPL2 license, [source](https://github.com/fedora-remix-mobility/u-boot)
- `uboot-fajita.img` - OnePlus 6T u-boot image, GPL2 license, [source](https://github.com/fedora-remix-mobility/u-boot)

### Enabled copr repositories

- [onesaladleaf/mobility-common](https://copr.fedorainfracloud.org/coprs/onesaladleaf/mobility-common) - [source](https://github.com/fedora-remix-mobility/packages)
- [onesaladleaf/pocketblue](https://copr.fedorainfracloud.org/coprs/onesaladleaf/pocketblue) - [source](https://github.com/pocketblue/packages)
- [onesaladleaf/sdm845](https://copr.fedorainfracloud.org/coprs/onesaladleaf/sdm845) - [forked from](https://copr.fedorainfracloud.org/coprs/g/mobility/sdm845), [source](https://github.com/fedora-remix-mobility/packages), [kernel source](https://github.com/fedora-remix-mobility/sdm845-kernel)
- [@mobility/gnome-mobile](https://copr.fedorainfracloud.org/coprs/g/mobility/gnome-mobile) - only enabled in the `oneplus6-gnome-mobile` image
