{
  description = "Yippeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    ...
  } @ inputs: let
    system = "x86_64-linux";
    lanzaboote = inputs.lanzaboote or null;
    nix-gaming = inputs.nix-gaming or null;
    nix-minecraft = inputs.nix-minecraft or null;
    nixos-cosmic = inputs.nixos-cosmic or null;
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {inherit lanzaboote nix-gaming nix-minecraft nixos-cosmic;};

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
