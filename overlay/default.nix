{ config, pkgs, lib, ... }:
let
  custom = (self: super: {
    awesome = self.callPackage ./awesome { };
  });

in
{
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  nixpkgs = {
    overlays = [
      custom
    ];
  };
}