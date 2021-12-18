#!/usr/bin/env bash

set -e

help() {
    echo "$0 <drive>"
    exit 0
}

disk=$1

if [ -z "$disk" ]; then
    help
fi

parted --list 2>/dev/null | grep -w "$disk" >/dev/null
if [[ $? -ne 0 ]]; then
    echo "No such drive."
    exit 1
fi

parted $disk print
read -r -p "Are you sure you want to use $disk? [y/N] (The drive will be formatted and the data lost) " response
response=${response,,} # tolower
if [[ ! $response =~ ^(yes|y) ]] || [[ -z $response ]]; then
    echo "Canceled"
    exit 0
fi

# Ram
RAM=$(free --gibi | head -2 | tail -1 | awk '{print $2}')
RAM=$(echo $RAM | awk '{print $disk + int(sqrt($disk))}')
RAM=$(echo $RAM | awk '{print int($0+1)}')
RAM=$(printf "%.0f" $RAM)

# Table
parted -s $disk mklabel "gpt"

# Boot Parition
parted -s $disk mkpart "ESP" "fat32" "1M" "1024MiB"
parted -s $disk set 1 boot on
partition1=$(lsblk -np --output KNAME | grep "^$disk.1\$")
mkfs.vfat "$partition1"

# Crypt lvm
parted -s $disk mkpart "crypt" "1024MiB" "100%"
partition2=$(lsblk -np --output KNAME | grep "^$disk.2\$")

dd if=/dev/urandom of=./keyfile-vgNix.bin bs=1024 count=4
cryptsetup luksFormat -q --type luks1 -c aes-xts-plain64 -s 256 -h sha512 "$partition2"
cryptsetup luksAddKey -q "$partition2" keyfile-vgNix.bin
cryptsetup luksOpen -q "$partition2" cryptlvm -d keyfile-vgNix.bin

pvcreate /dev/mapper/cryptlvm
vgcreate vgNix /dev/mapper/cryptlvm

lvcreate -L "$RAM"GiB vgNix -n swap
lvcreate -l 100%FREE vgNix -n root

mkswap -L swap /dev/mapper/vgNix-swap
mkfs.ext4 -L root /dev/mapper/vgNix-root

mount /dev/vgNix/root /mnt
mkdir -p /mnt/boot/efi
mount "$partition1" /mnt/boot/efi
swapon /dev/vgNix/swap

mkdir -p /mnt/etc/secrets/initrd/
cp keyfile-vgNix.bin /mnt/etc/secrets/initrd
chmod 000 /mnt/etc/secrets/initrd/keyfile*.bin

nixos-generate-config --root /mnt

nix-env -i git

mv /mnt/etc/nixos/hardware-configuration.nix /tmp/
rm -rf /mnt/etc/nixos/
git clone https://github.com/kilimnik/nixos /mnt/etc/nixos/
mv /tmp/hardware-configuration.nix /mnt/etc/nixos

nixos-install
reboot