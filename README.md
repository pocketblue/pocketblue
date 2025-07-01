# Pocketblue

Pocketblue is a custom Fedora Atomic image for mobile devices based on fedora-bootc and Fedora Mobility.
Currently only OnePlus 6/6T are supported.

### Installation

#### Disclaimer

This is a work-in-progress. During the installation process all data on your device will be wiped.
**Use at your own risk.**

#### 1. Download the partition images

Download the artifacts from the latest run of the [Build raw disk image](https://github.com/onesaladleaf/pocketblue/actions/workflows/build-image.yml) workflow in Github Actions

Extract the images:

```bash
mkdir images
unzip pocketblue.zip -d images
cd images
gzip -d esp.raw.gz boot.raw.gz root.raw.gz
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

Then reboot the device.
