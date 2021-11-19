{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    meslo-lgs-nf
  ];
}
