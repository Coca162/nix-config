{
  description = "Yippeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

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
