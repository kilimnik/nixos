{ config, pkgs, ... }:

{
  users.users.daniel = {
    name = "daniel";
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "adbusers" ];
    shell = pkgs.zsh;
    uid = 1000;
    home = "/home/daniel";
    hashedPassword = "$6$8joenBQsLS0rzlha$.YeNIyi76lMzdm97J1.3iP2MJOyemuvS3MmyrHAnHCIvNZuVzO0aTAZJT26E9hBw8raiwaqYzpnLzkmHID6/B0";
  };
}