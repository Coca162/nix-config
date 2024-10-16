{
  description = "Yippeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.flake = false;

    # nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    # nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixpkgs-small,
    home-manager,
    lix-module,
    rust-overlay,
    ...
  } @ inputs: let
    lanzaboote = inputs.lanzaboote or null;
    nixos-cosmic = inputs.nixos-cosmic or null;
    untuned-pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit nixpkgs-small lanzaboote nixos-cosmic untuned-pkgs nixpkgs rust-overlay;
        };

        modules = [
          lix-module.nixosModules.default
          ./modules/cosmic.nix
          ./modules/secureboot.nix
          ./configuration.nix
          ./main
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.coca = import ./home.nix;
          }
        ];
      };

      nicetop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit nixpkgs rust-overlay;
        };

        modules = [
          lix-module.nixosModules.default
          ./configuration.nix
          ./nicetop
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.coca = import ./home.nix;
          }
        ];
      };
    };
  };
}
