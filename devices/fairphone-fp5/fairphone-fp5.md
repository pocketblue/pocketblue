# Fairphone 5

## Device Information

| Property | Value |
|----------|-------|
| Manufacturer | Fairphone |
| Device | Fairphone 5 |
| Codename | fairphone-fp5 (FP5) |
| SoC | Qualcomm QCM6490 (Snapdragon 7 Gen 1) |
| Architecture | aarch64 |
| Release Year | 2023 |

## Current Status

The Fairphone 5 is supported by Pocketblue with the following desktop environments:

- GNOME Mobile (recommended)
- GNOME Desktop
- Plasma Mobile
- Plasma Desktop
- Phosh

### What Works

- Display
- Touchscreen
- GPU acceleration
- Audio (via ALSA UCM configuration for Qualcomm SC7280)
- Sensors (via libssc and iio-sensor-proxy)
- USB
- Modem/Telephony (via hexagonrpc, rmtfs, qrtr)
- WiFi
- Bluetooth

### What May Not Work or Has Limited Support

- Camera (mainline camera support is still in development)
- Some hardware-specific features

## Prerequisites

Before installing Pocketblue on your Fairphone 5, ensure you have:

1. **Unlocked bootloader** - The bootloader must be unlocked to flash custom images
2. **ADB and Fastboot tools** installed on your computer
3. **Backup of all important data** - The installation process will wipe all data on the device
4. **Sufficient battery charge** (at least 50% recommended)
5. **USB cable** for connecting the device to your computer

## Installation

### Step 1: Download the Image

Download the latest Pocketblue image for Fairphone 5 from the [GitHub Releases page](https://github.com/pocketblue/pocketblue/releases).

The recommended image is: `pocketblue-fairphone-fp5-gnome-mobile-<version>.7z`

Extract the archive using 7-Zip or a compatible tool:

```bash
7z x pocketblue-fairphone-fp5-gnome-mobile-42.7z
```

This will create an `images/` directory containing the required files.

### Step 2: Unlock the Bootloader

If you haven't already unlocked the bootloader:

1. Enable **Developer Options** by tapping the build number 7 times in Settings > About phone
2. Enable **OEM Unlocking** in Settings > System > Developer options
3. Boot into fastboot mode:
   - Power off the device
   - Hold **Volume Down + Power** until you see the fastboot screen
   - Or use: `adb reboot bootloader`
4. Unlock the bootloader:
   ```bash
   fastboot flashing unlock
   ```
5. Confirm the unlock on the device (this will factory reset the device)

### Step 3: Boot into Fastboot Mode

If not already in fastboot mode:

```bash
adb reboot bootloader
```

Or manually:
1. Power off the device
2. Hold **Volume Down + Power** until you see the fastboot screen

Verify the device is detected:

```bash
fastboot devices
```

### Step 4: Flash the Images

The extracted archive includes flash scripts that automate the flashing process.

**On Linux/macOS:**

```bash
./flash-fairphone-fp5.sh
```

**On Windows:**

```cmd
flash-fairphone-fp5.cmd
```

The script will flash the following partitions:
- `vbmeta_a` / `vbmeta_b` → Disabled verified boot image (both slots)
- `boot_a` / `boot_b` → U-Boot bootloader (both slots)
- `rawdump` → ESP partition (30MB)
- `logdump` → Boot partition (512MB)
- `userdata` → Root filesystem

The script will automatically reboot the device after flashing. The first boot may take longer than usual.

## Post-Installation

### Default Credentials

On first boot, you will be prompted to create a user account through the GNOME initial setup wizard.

### Updating the System

Pocketblue uses Fedora's atomic update system (bootc/rpm-ostree). To update:

```bash
# Check for updates
bootc upgrade --check

# Apply updates
bootc upgrade
```

### Installing Additional Software

See the [Installing Packages guide](https://pocketblue.github.io/tips-and-tricks/installing-packages) for information on:
- Using Flatpak for graphical applications
- Using toolbox for development environments
- Layering RPM packages with rpm-ostree

## Reverting to Stock Firmware

To return to the original Fairphone OS:

1. Download the official Fairphone 5 firmware from [Fairphone's support page](https://support.fairphone.com/)
2. Follow Fairphone's official flashing instructions

## Troubleshooting

### Device Not Detected in Fastboot

- Ensure USB debugging is enabled
- Try a different USB cable or port
- On Linux, check udev rules for Android devices
- On Windows, install appropriate USB drivers

### Boot Loop

- Try re-flashing all partitions
- Ensure the image was extracted correctly (not corrupted)

### No Display After Boot

- Wait several minutes - first boot may take time
- Connect via USB and check if the device is accessible via SSH over USB networking

## Technical Details

### Partition Layout

| Partition | Use | Size |
|-----------|-----|------|
| vbmeta_a / vbmeta_b | Disabled verified boot image | - |
| boot_a / boot_b | U-Boot bootloader | - |
| rawdump | ESP (EFI System Partition) | 30MB |
| logdump | Boot partition (kernel, initramfs) | 512MB |
| userdata | Root filesystem | Remaining space |

### Enabled Services

The following Qualcomm-specific services are enabled:

- `hexagonrpcd-adsp-rootpd.service` - ADSP root protection domain
- `hexagonrpcd-adsp-sensorspd.service` - ADSP sensors protection domain
- `hexagonrpcd-sdsp.service` - SDSP (Sensors DSP) service
- `tqftpserv.service` - TFTP server for firmware loading
- `qbootctl.service` - Qualcomm A/B boot control
- `rmtfs.service` - Remote filesystem service for modem

### Kernel

Pocketblue uses a mainline Linux kernel with patches for Qualcomm SC7280 (QCM6490) support from the [pocketblue/sc7280 COPR repository](https://copr.fedorainfracloud.org/coprs/pocketblue/sc7280/).

## Resources

- [Pocketblue GitHub Repository](https://github.com/pocketblue/pocketblue)
- [Pocketblue Telegram Chat](https://t.me/fedoramobility)
- [Fedora Mobility Matrix Room](https://matrix.to/#/#mobility:fedoraproject.org)
- [postmarketOS Fairphone 5 Wiki](https://wiki.postmarketos.org/wiki/Fairphone_5_(fairphone-fp5)) - Reference for hardware support status
- [Fairphone 5 Official Support](https://support.fairphone.com/)
