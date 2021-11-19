{ config, pkgs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    # Other
    pulseaudio

    # CLI
    vim htop git tmux mpv 
    screen ripgrep fd dfc ncdu 
    linuxPackages.perf pandoc
    p7zip file hexyl unzip zip
    zsh oh-my-zsh which graphviz
    docker-compose lua5_3 ncpamixer
    pamixer

    # networking
    wireshark wget networkmanager vnstat nmap 
    openvpn curl networkmanagerapplet

    ## Random
    asciiquarium lolcat neofetch

    ## Python 2.7
    python27
    python27Packages.pip
    python27Packages.virtualenv

    ## Python 3.9
    python39
    python39Packages.pip
    python39Packages.virtualenv 
    python39Packages.pwntools

    ## CTF
    strace gdb exiftool
    ltrace ghidra-bin


    # GUI
    chromium firefox albert rxvt_unicode
    feh nextcloud-client blender gimp
    keepassxc inkscape flameshot

    ## Games
    steam

    ## Social
    discord

    ## Dev
    vscode
  ];
}
