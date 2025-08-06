### Installation

#### 0. Previous installations

If you previously installed the system using U-Boot's mass storage mode, you must erase the previous EFI partition. You can do it through mass storage mode:

```bash
sudo wipefs -a /dev/disk/by-partlabel/op2
```

#### 1. Download the partition images

Download the artifacts of the latest "[images oneplus6](https://github.com/onesaladleaf/pocketblue/actions/workflows/images-oneplus6.yml)" workflow run

Extract the images:

```bash
unzip pocketblue-*.zip
rm pocketblue-*.zip
7z x pocketblue-*.7z
cd artifacts
```

#### 2. Download U-Boot

Download U-Boot from https://github.com/fedora-remix-mobility/u-boot/releases

- `uboot-sdm845-oneplus-enchilada.img` for OnePlus 6
- `uboot-sdm845-oneplus-fajita.img` for OnePlus 6T

#### 3. Flash the images

Target partitions:

- uboot-\*.img -> boot_\*
- boot.raw -> system_a
- esp.raw -> system_b
- root.raw -> userdata

```bash
fastboot erase dtbo

fastboot flash boot uboot-sdm845-oneplus-*.img --slot=all

fastboot flash system_a boot.raw
fastboot flash system_b esp.raw
fastboot flash userdata root.raw

# reboot, this might take a while
fastboot reboot
```

Wait for your device to reboot and boot into Pocketblue. You may have to reboot again if wifi, modem or bluetooth don't work.

- Default username: `user`
- Default password: `123456`

### Upgrading the system

Use rpm-ostree or bootc to upgrade the system to the latest image:

```bash
sudo rpm-ostree upgrade
# or
sudo bootc upgrade
```

After that, you should reboot your device. However, shutdown and reboot are currently
broken and may not work. To finish the upgrade process run the following command
before rebooting the device:

```bash
sudo systemctl stop ostree-finalize-staged.service
```

### Enabled copr repositories

- [@mobility/common](https://copr.fedorainfracloud.org/coprs/g/mobility/common) - [source](https://github.com/fedora-remix-mobility/packages)
- [onesaladleaf/pocketblue](https://copr.fedorainfracloud.org/coprs/onesaladleaf/pocketblue) - [source](https://github.com/onesaladleaf/pocketblue-rpms)
- [onesaladleaf/sdm845](https://copr.fedorainfracloud.org/coprs/onesaladleaf/sdm845) - [forked from](https://copr.fedorainfracloud.org/coprs/g/mobility/sdm845), [source](https://github.com/fedora-remix-mobility/packages), [kernel source](https://github.com/fedora-remix-mobility/sdm845-kernel)
- [@mobility/gnome-mobile](https://copr.fedorainfracloud.org/coprs/g/mobility/gnome-mobile) - only enabled in `quay.io/pocketblue/oneplus6-gnome-mobile` image
