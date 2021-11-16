{ config, pkgs, ... }:

{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
  };

  boot.initrd = {
    luks.devices."root" = {
      device = "/dev/disk/by-label/root";
      preLVM = true;
      keyFile = "/keyfile-vgNix.bin";
      allowDiscards = true;
    };
    secrets = {
      "keyfile-vgNix.bin" = "/etc/secrets/initrd/keyfile-vgNix.bin";
    };
  };
}