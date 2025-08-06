### using toolbox on arm linux

- `toolbox` preinstalled on all fedora atomic images
- `distrobox` is a nice alternative for toolbox, can be installed with `rpm-ostee install distrobox`

### currently broken on oneplus6

only work on mipad5, for oneplus6 pocketeblue currenty provides 6.15 linux kernel which have a bug that makes toolbox and distrobox broken, so if you use oneplus6 please wait for us to update kernel

### fedora

```shell
toolbox create --distro=fedora
```

### rhel

```shell
toolbox create --distro=rhel --release=10.0
```

### ubuntu

```shell
toolbox create --distro=ubuntu --release=24.04
```

### debian

```shell
toolbox create --image quay.io/toolbx-images/debian-toolbox
```

### alpine

```shell
toolbox create --image quay.io/toolbx-images/alpine-toolbox
```

### postmarket os

```shell
toolbox create --image quay.io/gmanka/pmos-toolbox
```

### arch

```shell
toolbox create --image quay.io/gmanka/arch-arm-toolbox
```

### additional info

- arch linux only had x86 images and didn't had arm toolbox images, so we built our own - https://github.com/gmanka-containers/arch-arm-toolbox
- postmarketos didn't had any toolbox images at all, so we built our own - https://github.com/gmanka-containers/pmos-toolbox

