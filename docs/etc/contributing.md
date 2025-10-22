# Contributing

Thanks for taking the time to help our project out! Here you will find information
that will help you contribute to Pocketblue

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Technical details](#technical-details)
  - [Build process](#build-process)
  - [Repository layout](#repository-layout)
    - [device.conf](#deviceconf)
- [Contribution guide](#contribution-guide)
  - [Adding a new device](#adding-a-new-device)
  - [Building using Github Actions in a forked repo](#building-using-github-actions-in-a-forked-repo)
  - [Testing your changes on a device running Pocketblue](#testing-your-changes-on-a-device-running-pocketblue)

## Technical details

### Build process

The images are built as regular OCI containers based on fedora-bootc and published to the
quay.io container registry

The build process of every final image is split into three containers built in a chain: `base -> device -> desktop`
- `base` image contains the common software required by all final images
- `device` images add device-specific packages like the kernel and firmware to the base image
- `desktop` images add a desktop environment and graphical applications

Container images are built using Github Actions by the containers.yml workflow

Flashable disk images are built using bootc-image-builder by the images.yml workflow

### Repository layout

- `base/` - base image recipe and files
- `devices/<device-name>/` - device images
  - `devices/<device-name>/device.conf` - various device configuration options, see [device.conf](#deviceconf)
- `desktops/<desktop-name>/` - desktop images
- `scripts/` - various scripts for building and flashing disk images
- `docs/` - documentation
- `config.toml` - bootc-image-builder config

#### device.conf

- `esp_size` - ESP size
- `install_dtb` - boolean, whether to install device trees to ESP

## Contribution guide

If you want to contribute changes to the repository you should:

1. fork the repository
2. make, commit and push your changes
3. build the container images and test the changes on your device (see below)
4. create a pull request

### Adding a new device

To add a new device, create a new subdirectory in `devices/` with the short name
for your device.

The directory should contain:
- a Containerfile with device-specific packages, e.g. the kernel and firmware
- any additional files required by your device, e.g. `.repo` files for your copr repositories
- a `device.conf` file containing the size of the EFI system partition

Please, avoid adding device-specific packages to base and desktop images.

If your device requires a custom kernel or firmware, you should publish them to
[Fedora COPR](https://copr.fedorainfracloud.org/) as RPM packages.
See [sm8150](https://github.com/pocketblue/sm8150) and [pipa-fedora-support](https://github.com/timoxa0/pipa-fedora-support)
for the example RPM specs.

Add a `scripts/<device_name>/artifacts_<device_name>.sh` script to compress and pack
your device's disk images into a 7z archive.

After adding a new container definition for your device, use Github Actions to build the images:
1. run the `containers` workflow to build the container images
2. run the `images` workflow to build the flashable disk images

Finally, flash the system to your device:
- find the suitable partitions to flash the root partition, the /boot partition and the ESP
- flash U-Boot (or any alternative that can boot EFI executables on your device) to the android boot partition
- flash boot.raw, esp.raw and root.raw using fastboot or U-Boot's mass storage mode
- reboot and test Pocketblue!

> [!CAUTION]
> Before flashing, make sure the chosen partitions can be safely flashed without bricking the device

### Building using Github Actions in a forked repo

1. create a classic github personal access token: https://github.com/settings/tokens/new?scopes=write:packages
2. go to the settings of your fork repo and open the `Secrets and variables -> Actions` section
3. add a repository secret with the name `REGISTRY_TOKEN` and value of your access token
4. add two repository variables:
  - name: `REGISTRY`, value: `ghcr.io/<github username>`
  - name: `REGISTRY_USERNAME`, value: your github username
5. you can now use Github Actions to build container images and disk images

### Testing your changes on a device running Pocketblue

1. reset all modifications of the system image: `sudo rpm-ostree reset`
2. switch to your image: `sudo bootc switch ghcr.io/<username>/<image name>:<tag>`
3. finalize the staged deployment: `sudo ostree admin finalize-staged`
4. reboot

If anything goes wrong, you can boot into the previous working image from the Grub menu
