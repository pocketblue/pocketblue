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
- Sensors (via libssc, hexagonrpcd, and iio-sensor-proxy-ssc)
- USB
- Modem/Telephony (via hexagonrpc, rmtfs, qrtr)
- WiFi
- Bluetooth (WCN6750 with WPSS firmware dependency)

### What May Not Work or Has Limited Support

- Camera (drivers present but CAMSS pipeline and sensor autoloading may need manual intervention)
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

The recommended image is: `pocketblue-fairphone-fp5-gnome-mobile-<version>.tar.xz`

Extract the archive using tar:

```bash
tar -xvJf pocketblue-fairphone-fp5-gnome-mobile-42.tar.xz
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

### Bluetooth Not Working

If Bluetooth is not activatable, check the following:

1. Verify firmware files are present (must be FairBlobs versions, not linux-firmware):
   ```bash
   ls -la /usr/lib/firmware/qca/msbtfw11.* /usr/lib/firmware/qca/msnv11.*
   # Should show:
   #   msbtfw11.mbn      (FairBlobs BT firmware, uncompressed)
   #   msbtfw11.tlv      (symlink -> msbtfw11.mbn)
   #   msnv11.bin        (FP5-specific NVM config from FairBlobs)
   #
   # Should NOT show any .xz or .zst compressed variants (those are from
   # linux-firmware and may be a different version, causing mismatch)
   ```

2. Check firmware is in initramfs (serdev probe fires at t=2.9s before ostree pivot):
   ```bash
   lsinitrd | grep -E "msbtfw|msnv"
   ```

3. Check kernel messages for firmware loading errors:
   ```bash
   dmesg | grep -iE "bluetooth|qca|hci|btqca"
   # Look for:
   #   "QCA Downloading qca/msbtfw11.mbn"  (or .tlv) -> good
   #   "QCA setup on UART is completed"     -> firmware loaded OK
   #   "Frame reassembly failed"            -> early probe failure
   #   "unexpected event for opcode"        -> HCI setup issue
   ```

4. Ensure rfkill is not blocking Bluetooth:
   ```bash
   rfkill list bluetooth
   rfkill unblock bluetooth
   ```

5. Restart the Bluetooth service:
   ```bash
   sudo systemctl restart bluetooth.service
   ```

### Orientation Sensor Not Working

Sensors on the Fairphone 5 are accessed via the ADSP (Audio DSP) subsystem
using Qualcomm's SSC (Sensor See Client) protocol through libssc. This
requires a patched version of iio-sensor-proxy with SSC support
(`iio-sensor-proxy-ssc` package from the pocketblue sc7280 COPR).

The stock Fedora `iio-sensor-proxy` does NOT have SSC support and will
not detect any sensors on the FP5.

1. Verify the SSC-patched iio-sensor-proxy is installed:
   ```bash
   rpm -q iio-sensor-proxy-ssc
   # If not installed, the stock iio-sensor-proxy won't work
   ```

2. Check if the ADSP fastrpc device is available:
   ```bash
   ls -la /dev/fastrpc-adsp
   ```

3. Check hexagonrpcd service status:
   ```bash
   sudo systemctl status hexagonrpcd-adsp-sensorspd.service
   ```

4. Verify sensor firmware is present:
   ```bash
   ls -la /usr/share/qcom/qcm6490/fairphone5/sensors/
   ```

5. Check iio-sensor-proxy status:
   ```bash
   sudo systemctl status iio-sensor-proxy.service
   ```

6. Restart the sensor stack:
   ```bash
   sudo systemctl restart hexagonrpcd-adsp-sensorspd.service
   sudo systemctl restart fairphone-fp5-sensors.service
   sudo systemctl restart iio-sensor-proxy.service
   ```

### Audio Not Working (LPASS Clock Controller Error)

The LPASS audio clock controller may fail to probe on first boot:

1. Check service status:
   ```bash
   sudo systemctl status fairphone-fp5-lpass-audio-rebind.service
   ```

2. Manually trigger rebind:
   ```bash
   sudo /usr/libexec/fairphone-fp5-lpass-audio-rebind
   ```

3. Restart audio services:
   ```bash
   sudo systemctl restart wireplumber.service pipewire.service
   ```

### GPU Firmware Errors

If you see `failed to load a660_sqe.fw` errors:

1. Verify GPU firmware:
   ```bash
   ls -la /usr/lib/firmware/qcom/qcm6490/fairphone5/a660_*
   ls -la /usr/lib/firmware/qcom/a660_*
   ```

2. The display should still work with fallback, but GPU acceleration may be affected

### Camera Not Working

Camera support on the Fairphone 5 requires the Qualcomm CAMSS (Camera Subsystem) driver and sensor-specific drivers.

**Current Status:**
- The kernel is configured with `CONFIG_VIDEO_QCOM_CAMSS=m` (CAMSS driver enabled)
- All FP5 camera sensor and lens drivers are enabled as modules
- Camera modules are loaded at boot via `modules-load.d/fairphone-fp5.conf`
- Module load ordering is enforced via `modprobe.d/fairphone-fp5.conf` softdeps

**Camera Hardware:**
| Camera | Sensor | Driver | Resolution |
|--------|--------|--------|------------|
| Main (rear) | Samsung S5KJN1 | `s5kjn1` | 50MP |
| Ultrawide (rear) | Sony IMX858 | `imx858` | 8MP |
| Front | Sony IMX471 | `imx471` | 32MP |
| Autofocus (rear) | Dongwoon DW9719 | `dw9719` | VCM |

**To check camera hardware detection:**

1. Verify camera modules are loaded:
   ```bash
   lsmod | grep -iE "camss|s5kjn1|imx858|imx471|dw9719|v4l2_cci"
   ```

2. Check if media and video devices are available:
   ```bash
   ls -la /dev/video*
   ls -la /dev/media*
   ls -la /dev/v4l-subdev*
   ```

3. Check kernel messages for camera-related drivers:
   ```bash
   dmesg | grep -iE "camss|s5kjn1|imx858|imx471|dw9719|cci|pm8008"
   ```

4. Inspect the media controller topology:
   ```bash
   media-ctl -p
   ```

5. Check libcamera detection:
   ```bash
   cam -l
   ```

6. If no media devices appear, try manually loading CAMSS:
   ```bash
   sudo modprobe qcom-camss
   dmesg | tail -20
   ```

## Technical Details

### Partition Layout

| Partition | Use | Size |
|-----------|-----|------|
| vbmeta_a / vbmeta_b | Disabled verified boot image | - |
| boot_a / boot_b | U-Boot bootloader | - |
| logdump | ESP (EFI System Partition) | 30MB |
| rawdump | Boot partition (kernel, initramfs) | 1024MB |
| userdata | Root filesystem | Remaining space |

### Enabled Services

The following device-specific services are enabled:

- `hexagonrpcd-adsp-sensorspd.service` - ADSP sensors protection domain for sensor access via libssc
- `tqftpserv.service` - TFTP server for firmware loading
- `qbootctl.service` - Qualcomm A/B boot control
- `rmtfs.service` - Remote filesystem service for modem
- `fairphone-fp5-usbc-rebind.service` - USB-C Type-C and DisplayPort Alt Mode initialization
- `fairphone-fp5-sensors.service` - Sensor stack initialization after ADSP is ready
- `fairphone-fp5-bluetooth.service` - Bluetooth initialization with WCN6750 recovery
- `fairphone-fp5-lpass-audio-rebind.service` - LPASS audio clock controller rebind

### Kernel

Pocketblue uses a mainline Linux kernel with patches for Qualcomm SC7280 (QCM6490) support from the [pocketblue/sc7280 COPR repository](https://copr.fedorainfracloud.org/coprs/pocketblue/sc7280/).

## Resources

- [Pocketblue GitHub Repository](https://github.com/pocketblue/pocketblue)
- [Pocketblue Telegram Chat](https://t.me/fedoramobility)
- [Fedora Mobility Matrix Room](https://matrix.to/#/#mobility:fedoraproject.org)
- [postmarketOS Fairphone 5 Wiki](https://wiki.postmarketos.org/wiki/Fairphone_5_(fairphone-fp5)) - Reference for hardware support status
- [Fairphone 5 Official Support](https://support.fairphone.com/)
