# Fairphone 5

## Device Information

| Property | Value |
|----------|-------|
| Manufacturer | Fairphone |
| Device | Fairphone 5 |
| Codename | fairphone-fp5 (FP5) |
| SoC | Qualcomm SC7280/QCM6490/Kodiak (Snapdragon 7 Gen 1) |
| Architecture | aarch64 |
| Release Year | 2023 |

## Current Status

The Fairphone 5 is supported by Pocketblue with the following desktop environments:

- GNOME Desktop (recommended)
- Plasma Mobile
- Plasma Desktop
- Phosh

### What Works

- Internal display (DSI, 300% auto-default via mutter patch)
- External display (DP alt-mode over USB-C, with touch input via USB 2.0 hub)
- Touchscreen (Goodix Berlin SPI)
- GPU acceleration (Adreno 643)
- Audio (speaker, earpiece, headset via Q6 DSP — UCM profile `qcm6490`)
- USB (host, device, USB-C role switching)
- Modem / telephony (voice, SMS, mobile data via IPA + QMI)
- GPS / GNSS
- WiFi (WCN6750)
- Bluetooth (WCN6750 via UART)
- Cameras — front (S5KJN1) and rear wide (IMX858) via CAMSS + libcamera
- Haptic motor (AW86927 vibrator)
- Flashlight / camera flash LED (`white:flash`)
- Night Light / color temperature (with mutter EDID fallback patch)
- Sensors — accelerometer, ambient light, proximity (via ADSP SSC)
- Auto-brightness (ambient light sensor via SSC)
- Display auto-rotation

### What Doesn't Work Yet

- Rear main camera (Sony IMX800 — requires C-PHY support, no upstream driver)
- Fingerprint reader (no upstream driver)
- NFC

### Known Issues

- Bluetooth may require a service restart after boot (see [Troubleshooting](#bluetooth-not-working))
- CCI I2C timeout on boot is harmless (see [Troubleshooting](#cci-i2c-timeout-camera-bus))

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

The Fairphone 5 uses the WCN6750 Bluetooth controller connected via UART (serdev).

**Known Issue: Invalid BD Address**

The WCN6750 may report an invalid BD address (e.g., `00:00:00:00:5A:AD` or
`00:00:00:00:00:00`) if the NVM configuration doesn't contain a valid address.
BlueZ rejects controllers with invalid addresses, causing the "Unconfigured
Index Removed" event in btmon.

The `set-bt-mac` script runs before BlueZ starts and sets a stable BD address
derived from the device serial number (similar to postmarketOS's bootmac).

**Troubleshooting Steps:**

1. Check the current BD address:
   ```bash
   cat /sys/class/bluetooth/hci0/address
   # If it shows 00:00:00:00:00:00 or similar, the address needs to be set
   ```

2. Verify firmware files are present:
   ```bash
   ls -la /usr/lib/firmware/qca/msbtfw11.* /usr/lib/firmware/qca/msnv11.*
   # Should show msbtfw11.mbn, msbtfw11.tlv (symlink), and msnv11.bin
   ```

3. Check firmware is in initramfs:
   ```bash
   lsinitrd | grep -E "msbtfw|msnv"
   ```

4. Check kernel messages:
   ```bash
   dmesg | grep -iE "bluetooth|qca|hci|btqca"
   # Look for "QCA setup on UART is completed" -> success
   ```

5. Check rfkill:
   ```bash
   rfkill list bluetooth
   rfkill unblock bluetooth
   ```

6. Manually run the BD address setup:
   ```bash
   sudo /usr/libexec/set-bt-mac
   sudo systemctl restart bluetooth.service
   ```

7. If issues persist, reload the modules:
   ```bash
   sudo modprobe -r pwrseq_core hci_uart btqca
   sudo modprobe hci_uart
   sleep 3
   sudo systemctl restart bluetooth.service
   ```

### Orientation Sensor / Auto-Rotation Not Working

Sensors on the Fairphone 5 are accessed via the ADSP (Audio DSP) subsystem
using Qualcomm's SSC (Sensor See Client) protocol through libssc. This
requires a patched version of iio-sensor-proxy with SSC support
(`iio-sensor-proxy-ssc` package from the pocketblue sc7280 COPR).

The stock Fedora `iio-sensor-proxy` does NOT have SSC support and will
not detect any sensors on the FP5.

1. Verify the SSC-patched iio-sensor-proxy is installed:
   ```bash
   rpm -q iio-sensor-proxy
   ldd /usr/libexec/iio-sensor-proxy | grep libssc
   # Must show libssc.so — the stock Fedora package does NOT have SSC support
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
   ls -la /usr/share/qcom/qcm6490/Fairphone/fp5/sensors/
   ```

5. Verify the ADSP sensor calibration directory exists:
   ```bash
   ls -la /mnt/vendor/persist/sensors/registry/
   # Should exist and be writable. If missing, create it:
   sudo mkdir -p /mnt/vendor/persist/sensors/registry/registry
   sudo chmod -R 0777 /mnt/vendor/persist/sensors
   ```
   The ADSP firmware writes sensor calibration data here. Without this
   directory, sensors may detect but not return valid data.

6. Check iio-sensor-proxy status and systemd dependencies:
   ```bash
   sudo systemctl status iio-sensor-proxy.service
   systemctl cat iio-sensor-proxy.service  # Should show hexagonrpcd dependency
   ```

7. Restart the sensor stack:
   ```bash
   sudo systemctl restart hexagonrpcd-adsp-sensorspd.service
   sudo systemctl restart iio-sensor-proxy.service
   ```

### Audio Not Working (LPASS Clock Controller Error)

The LPASS audio clock controller may fail to probe on first boot with
`error -110` (ETIMEDOUT). This is a known issue where the ADSP
remoteproc is not ready in time. A reboot usually resolves it.

Restart audio services:
```bash
sudo systemctl restart wireplumber.service pipewire.service
```

### CCI I2C Timeout (Camera Bus)

You may see errors like:
```
i2c-qcom-cci ac4a000.cci: master 0 queue 0 timeout
```

This is **harmless** and occurs when the CCI (Camera Control Interface)
I2C bus tries to enumerate devices before the PM8008 camera PMIC has
initialized the I2C pull-up voltage (`vreg_l6p`). The CCI driver
recovers automatically by resetting and reinitializing the controller.

This timeout is most commonly seen on CCI0 master 0, which connects to
the main rear camera (IMX800) EEPROM. Since the IMX800 driver is not
yet upstream (it uses C-PHY), its associated devices may not respond.

The cameras that ARE supported (IMX858 wide, S5KJN1 front) use different
CCI buses and are not affected by this timeout.

### SELinux AVC Denials

Pocketblue runs with SELinux enabled. If something isn't working, check for
AVC (Access Vector Cache) denials:

1. Check for denials since boot:
   ```bash
   sudo ausearch -m avc -ts boot
   ```

2. Understand why a denial occurred:
   ```bash
   sudo ausearch -m avc -ts boot --raw | audit2why
   ```

3. Generate a policy module to allow the denied action:
   ```bash
   sudo ausearch -m avc -ts boot --raw | audit2allow -a
   ```
   Review the output carefully — `audit2allow` may suggest overly broad rules.
   Prefer file context fixes (`semanage fcontext`) over blanket allow rules.

4. Check file contexts (mislabeled files are the most common cause):
   ```bash
   # Show expected vs actual label
   ls -Z /path/to/file
   matchpathcon /path/to/file

   # Fix labels recursively
   sudo restorecon -Rv /path/to/directory

   # Check if a file context rule exists
   sudo semanage fcontext -l | grep 'pattern'
   ```

5. Add a custom file context rule (if missing from base policy):
   ```bash
   sudo semanage fcontext -a -t <type> '/path/pattern(/.*)?'
   sudo restorecon -Rv /path
   ```

6. Temporarily switch to permissive mode for debugging:
   ```bash
   sudo setenforce 0    # permissive (logs but allows)
   sudo setenforce 1    # enforcing
   getenforce           # check current mode
   ```

Custom SELinux policy modules for pocketblue are shipped as CIL files in
`/usr/share/selinux/packages/` and installed during image build via `semodule`.

### GPU Firmware Errors

If you see `failed to load a660_sqe.fw` errors:

1. Verify GPU firmware:
   ```bash
   ls -la /usr/lib/firmware/qcom/qcm6490/fairphone5/a660_*
   ls -la /usr/lib/firmware/qcom/a660_*
   ```

2. The display should still work with fallback, but GPU acceleration may be affected

### Camera Not Working

Camera support uses the Qualcomm CAMSS driver, sensor-specific drivers, and
libcamera with tuning files. Two of the three cameras work.

**Camera Hardware:**

All three cameras must be physically installed in the device for any of them
to work (they share power rails via the PM8008 camera PMIC).

| Purpose | Sensor | PHY | Driver | Status |
|---------|--------|-----|--------|--------|
| Front (selfie) | Samsung S5KJN1SQ03 | D-PHY | `s5kjn1` | Working |
| Rear (wide) | Sony IMX858 | D-PHY | `imx858` | Working |
| Rear (main) | Sony IMX800 | C-PHY | — | No upstream driver |
| Wide autofocus | Dongwoon DW9800K | — | `dw9719` | Working |

The main rear camera (IMX800) uses C-PHY (not D-PHY) and has no upstream
Linux driver or CAMSS C-PHY support yet. Its actuators (AK7377, DW9784 OIS)
also lack upstream drivers.

#### Debugging Camera Issues

1. Verify camera modules are loaded:
   ```bash
   lsmod | grep -iE "camss|s5kjn1|imx858|dw9719|v4l2_cci"
   ```

2. Check if media and video devices are available:
   ```bash
   ls -la /dev/video*
   ls -la /dev/media*
   ls -la /dev/v4l-subdev*
   ```

3. Check kernel messages for camera-related drivers:
   ```bash
   dmesg | grep -iE "camss|s5kjn1|imx858|dw9719|cci|pm8008"
   ```

4. Check for deferred probes (common with PMIC/regulator dependencies):
   ```bash
   cat /sys/kernel/debug/devices_deferred
   ```

5. Inspect the media controller topology:
   ```bash
   media-ctl -p
   ```

6. Check libcamera detection and available pipelines:
   ```bash
   cam -l
   LIBCAMERA_LOG_LEVELS=*:DEBUG cam -l 2>&1 | head -50
   ```

7. Check if libcamera tuning files are present:
   ```bash
   ls -la /usr/share/libcamera/ipa/simple/imx858.yaml
   ls -la /usr/share/libcamera/ipa/simple/s5kjn1.yaml
   ```

8. If no media devices appear, try manually loading CAMSS:
   ```bash
   sudo modprobe qcom-camss
   dmesg | tail -20
   ```

## Tips

### Flashlight / Camera Flash LED

The flash LED is exposed via the standard Linux LED subsystem:

```bash
# Torch on
echo 1 > /sys/class/leds/white:flash/brightness
# Torch off
echo 0 > /sys/class/leds/white:flash/brightness
# Activate flash strobe
echo 1 > /sys/class/leds/white:flash/flash_strobe
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

- `hexagonrpcd-adsp-sensorspd.service` - ADSP sensors protection domain (libssc sensor access)
- `hexagonrpcd-adsp-rootpd.service` - ADSP root protection domain
- `bluetooth.service` - BlueZ daemon (with FP5 drop-in for WCN6750 timing)
- `tqftpserv.service` - TFTP server for firmware loading
- `qbootctl.service` - Qualcomm A/B boot control
- `rmtfs.service` - Remote filesystem service for modem

The `set-modem-sim-slot.service` is started as a dependency of ModemManager
(via drop-in), not enabled directly. `bootloader-update.service` is masked
(FP5 uses Android A/B boot, not bootupd/EFI).

### Device Configuration Files

| File | Purpose |
|------|--------|
| `/usr/lib/udev/rules.d/80-fairphone-fp5.rules` | Accelerometer mount matrix and SSC sensor types |
| `/usr/lib/modprobe.d/fairphone-fp5.conf` | Camera module softdeps for load ordering |
| `/usr/lib/modules-load.d/fairphone-fp5.conf` | Explicit module loading (camera, BT) |
| `/usr/lib/dracut/dracut.conf.d/50-fairphone-fp5.conf` | Initramfs firmware and driver inclusion |
| `/usr/lib/tmpfiles.d/fairphone-fp5.conf` | tmpfiles configuration (runtime dirs, ADSP sensor calibration persist directory) |
| `/usr/libexec/set-bt-mac` | WCN6750 BD address setup script (sets stable address before BlueZ starts) |
| `/usr/libexec/set-modem-sim-slot` | SIM provisioning session binding for modem (run before ModemManager) |
| `/usr/libexec/fairphone-fp5-debug` | Device debug info collection script |
| `/usr/lib/systemd/system/bluetooth.service.d/10-fairphone-fp5.conf` | BT service drop-in (hci0 dependency, pre-start HCI recovery) |
| `/usr/lib/systemd/system/ModemManager.service.d/10-fairphone-fp5.conf` | ModemManager drop-in (waits for SIM slot provisioning) |
| `/usr/lib/systemd/system/iio-sensor-proxy.service.d/10-fairphone-fp5.conf` | Sensor proxy dependency ordering |
| `/etc/xdg/monitors.xml` | Default display scale (2.4x for 1224x2700 DSI panel) |
| `/usr/share/selinux/packages/iio-sensor-proxy-qrtr.cil` | SELinux policy for QRTR socket access |
| `/usr/share/selinux/packages/systemd-system-control.cil` | SELinux file context for `/etc/systemd/system.control/` |
| `/usr/lib/bootc/kargs.d/90-fairphone-fp5.toml` | Kernel boot arguments (`clk_ignore_unused`, `earlycon=efifb`) |

### Kernel

Pocketblue uses a Fedora ark-based kernel (via arkify) with additional patches for Qualcomm SC7280 (QCM6490/Kodiak) support, built via the [pocketblue/sc7280 COPR repository](https://copr.fedorainfracloud.org/coprs/pocketblue/sc7280/).

#### Boot Arguments

Device-specific kernel arguments are shipped in `/usr/lib/bootc/kargs.d/90-fairphone-fp5.toml`:

- **`clk_ignore_unused`** — Required on Qualcomm SoCs with modular drivers.
  Prevents the kernel from disabling unclaimed clocks at boot, which would
  kill TrustZone-owned clocks and trigger a hard reset.

- **`earlycon=efifb`** — Early console via U-Boot's EFI GOP framebuffer.
  Shows kernel output before the DRM console driver loads, so panics during
  early boot are visible on screen. Automatically unregistered once the
  proper console takes over.

## Resources

- [Pocketblue GitHub Repository](https://github.com/pocketblue/pocketblue)
- [Fedora Mobility Matrix Room](https://matrix.to/#/#mobility:fedoraproject.org)
- [postmarketOS Fairphone 5 Wiki](https://wiki.postmarketos.org/wiki/Fairphone_5_(fairphone-fp5)) - Reference for hardware support status
- [Fairphone 5 Official Support](https://support.fairphone.com/)
