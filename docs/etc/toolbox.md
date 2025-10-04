### what is toolbox

- toolbox is a tool that creates container with any linux distro
- in toolbox containers you can install any packages from any linux distro
- if you want to use `dnf` on fedora atomic, it's strongly recommended to use toolbox
- preinstalled on all fedora atomic images

### what is distrobox

- distrobox is a nice alternative for toolbox
- can be installed with `rpm-ostee install distrobox`

### currently broken on oneplus 6 and oneplus 6t

for oneplus 6 and oneplus 6t pocketeblue currently provides 6.15 linux kernel which have a bug that makes toolbox and distrobox broken, so if you use oneplus6 please wait for us to update kernel

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

### arch arm

```shell
toolbox create --image quay.io/gmanka/arch-arm-toolbox
```

### additional info

- arch linux only had x86 images and didn't had arm toolbox images, so we built our own - https://github.com/gmanka-containers/arch-arm-toolbox
- postmarketos didn't had any toolbox images at all, so we built our own - https://github.com/gmanka-containers/pmos-toolbox

