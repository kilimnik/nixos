#!/usr/bin/env bash

help() {
    echo "$0 <drive>"
    exit 0
}

if [ -z "$1" ]; then
    help
fi

parted --list 2>/dev/null | grep -w "$1" >/dev/null
if [[ $? -ne 0 ]]; then
    echo "No such drive."
    exit 1
fi

parted $1 print
read -r -p "Are you sure you want to use $1? [y/N] (The drive will be formatted and the data lost) " response
response=${response,,} # tolower
if [[ ! $response =~ ^(yes|y) ]] || [[ -z $response ]]; then
    echo "Canceled"
    exit 0
fi

# Ram
RAM=$(free --gibi | head -2 | tail -1 | awk '{print $2}')
RAM=$(echo $RAM | awk '{print $1 + int(sqrt($1))}')
RAM=$(echo $RAM | awk '{print int($0+1)}')
RAM=$(printf "%.0f" $RAM)

# Table
parted -s $1 mklabel "gpt"

# Boot Parition
parted -s $1 mkpart "ESP" "fat32" "1M" "1024MiB"
parted -s $1 set 1 boot on
mkfs.vfat "$11"

# Crypt lvm
parted -s $1 mkpart "primary" "1024MiB" "100%"

dd if=/dev/urandom of=./keyfile-vgNix.bin bs=1024 count=4
cryptsetup luksFormat -q -c aes-xts-plain64 -s 256 -h sha512 "$12"
cryptsetup luksAddKey -q "$12" keyfile-vgNix.bin
cryptsetup luksOpen -q "$12" cryptlvm -d keyfile-vgNix.bin

pvcreate /dev/mapper/cryptlvm
vgcreate vgNix /dev/mapper/cryptlvm

lvcreate -L "$RAM"GiB vgNix -n swap
lvcreate -l 100%FREE vgNix -n root

mkswap -L swap /dev/mapper/vgNix-swap
mkfs.ext4 -L root /dev/mapper/vgNix-root

mount /dev/vgNix/root /mnt
mkdir -p /mnt/boot/efi
mount "$11" /mnt/boot/efi
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