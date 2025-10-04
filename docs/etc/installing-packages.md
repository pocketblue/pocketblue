### how to install packages on fedora atomic

- the recommended way to install most appilications is flatpak, see [flathub](https://flathub.org)
- we also have our own flatpak repo with mobile config for firefox, see [pocketblue flatpak repo](https://github.com/pocketblue/pocketblue.github.io)

### using dnf in toolbox

if you want to use `dnf` on fedora atomic, it's strongly recommended to use [toolbox](toolbox.md)

### upgrading system

use `bootc upgrade` or `rpm-ostree upgrade`

### installing packages to system

on atomic systems installing packages to system is not recommended, but you can do it using `rpm-ostree install`
