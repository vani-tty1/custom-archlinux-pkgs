# custom-archlinux-pkgs

This repo is meant for building packages with a custom build option
that is not set in the official [Arch Linux Gitlab](gitlab.archlinux.org) 
or building [AUR](aur.archlinux.org) packages



## How it works

A [CI workflow](.github/workflows/buildpkg.yml) discovers every folder containing a
PKGBUILD and runs `makepkg -sf --noconfirm --needed` inside each one, so you could consider
it as a build infrastructure for a curated set of custom packages.
