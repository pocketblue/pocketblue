# Pocketblue

Pocketblue is a custom Fedora Atomic image for mobile devices based on fedora-bootc and Fedora Mobility.
Currently only OnePlus 6/6T are supported. Xiaomi Mi Pad 5 support is in the works.

### Installation

#### Disclaimer

This is a work-in-progress. During the installation process all data on your device will be wiped.
**Use at your own risk.**

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

### Related projects

- [fedora-remix-mobility/fedora-kiwi-descriptions](https://github.com/fedora-remix-mobility/fedora-kiwi-descriptions) - KIWI image descriptions for Fedora Mobility
- [sdm845-live-fedora](https://github.com/samcday/sdm845-live-fedora) - a compact Fedora UKI that can be directly booted from the OnePlus6(T) bootloader
