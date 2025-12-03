#!/bin/sh

int_handler () {
    jobs -p | xargs --no-run-if-empty kill 2>/dev/null || true
    exit 130
}

trap int_handler INT TERM

nix-build \
    '<nixpkgs/nixos>' \
    --attr config.system.build.isoImage \
    --include nixpkgs="channel:nixos-${CHANNEL}" \
    --include nixos-config="${CONFIG_PATH}" \
    --option filter-syscalls false \
    --show-trace \
&& \
cp -L result/iso/*.iso "${ISO_PATH}" \
&& \
chmod u+w "${ISO_PATH}" \
&& \
rm result \
&& \
echo;
