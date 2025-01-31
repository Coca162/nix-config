{
  description = "Yippeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.rust-overlay.follows = "rust-overlay";

    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
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
    specialArgs = {
      lanzaboote = inputs.lanzaboote or null;
      nixos-cosmic = inputs.nixos-cosmic or null;
    };
    shared-modules = [
      ./configuration.nix
      lix-module.nixosModules.default
      home-manager.nixosModules.home-manager
      {
        # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

        # Keep nixPath so we don't have to use flakes for projects
        nix.nixPath = [
          "nixpkgs=${nixpkgs}"
          "rust-overlay=${rust-overlay}"
        ];
      }
    ];
    shared-graphical =
      [
        ./modules/cosmic.nix
        ./graphical.nix
      ]
      ++ shared-modules;
  in {
    nixosConfigurations = {
      nicetop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [./nicetop] ++ shared-graphical;
      };

      tiberius = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [./tiberius] ++ shared-modules;
      };
    };
  };
}
