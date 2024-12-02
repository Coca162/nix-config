{
  description = "Yippeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.rust-overlay.follows = "rust-overlay";

    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    # nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
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
    flake-only = {
      # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
      nix.registry.nixpkgs.flake = nixpkgs;
      nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

      # Keep nixPath so we don't have to use flakes for projects
      nix.nixPath = [
        "nixpkgs=${nixpkgs}"
        "rust-overlay=${rust-overlay}"
      ];
    };
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit lanzaboote nixos-cosmic untuned-pkgs;
        };

        modules = [
          lix-module.nixosModules.default
          ./modules/cosmic.nix
          ./modules/secureboot.nix
          ./configuration.nix
          ./main
          flake-only
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.coca = import ./home.nix;
          }
        ];
      };

      nicetop = nixpkgs.lib.nixosSystem {
        modules = [
          lix-module.nixosModules.default
          ./configuration.nix
          ./nicetop
          flake-only
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
