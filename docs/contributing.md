# Contributing

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
  - `devices/<device-name>/device.conf` - currently only contains one parameter - ESP size in bytes used when building disk images
- `desktops/<desktop-name>/` - desktop images
- `scripts/` - various scripts for building and flashing disk images
- `docs/` - documentation
- `config.toml` - bootc-image-builder config

## Contribution guide

### Contributing code

If you want to contribute changes to the repository you should:
1. Fork the repository
2. Make, commit and push your changes
3. Build the container images and test the changes on your device (see below)
4. Create a Pull Request

### Building containers in a forked repo

1. create a classic github personal access token: https://github.com/settings/tokens/new?scopes=write:packages
2. go to the settings of your fork repo and open the `Secrets and variables -> Actions` section
3. add a repository secret with the name `REGISTRY_TOKEN` and value of your access token
4. add two repository variables:
  a. name: `REGISTRY`, value: `ghcr.io/<github username>`
  b. name: `REGISTRY_USERNAME`, value: your github username
5. go to Github Actions and run the `containers` action against your branch
6. wait for the build to finish
7. you can now rebase to your image using the `sudo bootc switch ghcr.io/<username>/<image name>:<tag> && sudo ostree admin finalize-staged` command
