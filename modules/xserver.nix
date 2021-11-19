{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";
    xkbVariant = "altgr-intl";
  
    displayManager = {
        sddm = {
            enable = true;
            autoNumlock = true;
        };

        defaultSession = "none+awesome";
    };

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks # is the package manager for Lua modules
        luadbi-mysql # Database abstraction layer
      ];
    };
  };
}