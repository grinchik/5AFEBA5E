# 5AFEBA5E

Automated builder for provisioned, reproducible NixOS live ISO images with pre-configured networking, SSH authentication, and a predefined set of packages.


## Prerequisites

### macOS built-in tools
* `make`
* `curl`
* `diskutil`
* `dd`
* `ssh-keygen`

### also required
* `envsubst` (part of `gettext` in Homebrew)
* Docker


## Usage

### Build ISO image

`SSH_PUBLIC_KEY_FILEPATH` specifies the path to your SSH public key used for authentication:

```sh
make iso SSH_PUBLIC_KEY_FILEPATH=~/.ssh/id_ed25519.pub
```

### Flash USB drive

`DISK_PATH` specifies the target disk for flashing:

> [!CAUTION]
> This operation will completely overwrite the target disk. Make sure you have selected the correct device to avoid data loss.

```sh
make flash DISK_PATH=/dev/diskX
```

Replace `/dev/diskX` with the actual path to your target disk. Use `diskutil list` to identify the correct device.
