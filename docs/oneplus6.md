### Installation

#### 1. Download the partition images

Download the artifacts of the latest "[images oneplus6](https://github.com/onesaladleaf/pocketblue/actions/workflows/images-oneplus6.yml)" workflow run

Extract the images:

```bash
unzip pocketblue-*.zip
rm pocketblue-*.zip
7z x pocketblue-*.7z
cd artifacts
```

#### 2. Download and flash U-Boot

Download U-Boot from https://github.com/fedora-remix-mobility/u-boot/releases

- `uboot-sdm845-oneplus-enchilada.img` for OnePlus 6
- `uboot-sdm845-oneplus-fajita.img` for OnePlus 6T

Flash U-Boot to your device:

```bash
fastboot erase dtbo_a
fastboot erase dtbo_b
fastboot flash boot uboot-sdm845-oneplus-*.img --slot=all
fastboot reboot
```

The device will boot into U-Boot menu. Select the `enable usb mass storage` option with volume keys and press the power button.

#### 3. Flash Pocketblue

Find the target partitions:

```bash
lsblk -o NAME,PARTLABEL | grep -E 'op2|system|userdata'
```

Example output:

```
├─sda7  op2
├─sda13 system_a
├─sda14 system_b
└─sda17 userdata
```

Write the images:

- esp.raw -> op2
- boot.raw -> system_a
- root.raw -> userdata

```bash
sudo dd if=esp.raw  of=/dev/sda7  bs=4M status=progress
sudo dd if=boot.raw of=/dev/sda13 bs=4M status=progress
sudo wipefs -a /dev/sda14 # system_b is not used
sudo dd if=root.raw of=/dev/sda17 bs=4M status=progress
sync
```

Reboot the device.

- Default username: `user`
- Default password: `123456`


### Upgrading the system

Use rpm-ostree to upgrade the system to the latest image:

```bash
sudo rpm-ostree upgrade
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
