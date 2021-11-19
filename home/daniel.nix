{awesome-lain}: {pkgs, lib, ... }:

{
  home.file = {
    "awesome" = {
      source = pkgs.symlinkJoin {
        name = "aweomseConfig";
        paths = [
          ./res/awesome 
          (pkgs.linkFarm "lain" [{
            name="lain";
            path = awesome-lain;
          }])
        ];
      };
      target = "./.config/awesome";
    };

    "albert" = {
      source = ./res/albert/albert.conf;
      target = "./.config/albert/albert.conf";
    };

    "alacritty" = {
      source = ./res/alacritty/alacritty.yml;
      target = "./.config/alacritty/alacritty.yml";
    };

    "powerlevel10k" = {
      source = ./res/powerlevel10k/.p10k.zsh;
      target = "./.p10k.zsh";
    };
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;

      initExtra = ''
neofetch
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
'';

      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        save = 10000;
        share = true;
        size = 10000;
      };

      zplug = {
        enable = true;
        plugins = [
          { name = "plugins/adb"; tags = [from:oh-my-zsh]; }
          { name = "plugins/bgnotify"; tags = [from:oh-my-zsh]; }
          { name = "plugins/cargo"; tags = [from:oh-my-zsh]; }
          { name = "plugins/catimg"; tags = [from:oh-my-zsh]; }
          { name = "plugins/colored-man-pages"; tags = [from:oh-my-zsh]; }
          { name = "plugins/emoji-clock"; tags = [from:oh-my-zsh]; }
          { name = "plugins/pip"; tags = [from:oh-my-zsh]; }
          { name = "plugins/yarn"; tags = [from:oh-my-zsh]; }
          
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
          { name = "romkatv/powerlevel10k"; tags = [as:theme depth:1]; }
        ];
      };
    };

    alacritty = {
      enable = true;
    };
  };
}