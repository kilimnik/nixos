{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    awesome-lain.url = "github:lcpz/lain";
    awesome-lain.flake = false;
  };

  outputs = { home-manager, nixpkgs, awesome-lain, ... }: {
    nixosConfigurations = {
      daniel-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.daniel = import ./home/daniel.nix {
              inherit awesome-lain;
            };
          }
        ];
      };
    };
  };
}