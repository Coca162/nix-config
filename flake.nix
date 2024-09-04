{
  description = "Yippeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";

    # nix-gaming.url = "github:fufexan/nix-gaming";
    # nix-gaming.inputs.nixpkgs.follows = "nixpkgs";

    # nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    # nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";

    # nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    # nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    home-manager,
    lix-module,
    nixos-unstable-small,
    ...
  } @ inputs: let
    lanzaboote = inputs.lanzaboote or null;
    nix-gaming = inputs.nix-gaming or null;
    nix-minecraft = inputs.nix-minecraft or null;
    nixos-cosmic = inputs.nixos-cosmic or null;
    untuned-pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit lanzaboote nix-gaming nix-minecraft nixos-cosmic untuned-pkgs nixos-unstable-small;
        };

        modules = [
          lix-module.nixosModules.default
          ./modules/cosmic.nix
          ./modules/minecraft.nix
          ./modules/secureboot.nix
          ./modules/osu-lazer.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.coca = import ./home.nix;
            home-manager.users.testing = import ./home.nix;
          }
        ];
      };
    };
  };
}
