{
  description = "Yippeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    home-manager,
    lix-module,
    rust-overlay,
    ...
  }: let
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
  in {
    nixosConfigurations = {
      nicetop = nixpkgs.lib.nixosSystem {
        modules = [./nicetop ./graphical.nix] ++ shared-modules;
      };

      tiberius = nixpkgs.lib.nixosSystem {
        modules = [./tiberius] ++ shared-modules;
      };
    };
  };
}
