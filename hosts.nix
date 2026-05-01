let
  sources = import ./npins;

  lib = import "${sources.nixpkgs}/lib";
  pkgs = import sources.nixpkgs {
    overlays = [(import ./packages)];

    config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "osu-lazer-bin"
        "bitwig-studio-unwrapped"
        "bitwig-studio6"
        "bitwig-studio6-6.0"
        "aseprite" # Source available
        "obsidian"
        "reaper"
        "steam"
        "steam-unwrapped"
      ]
      # TODO: Find a better way to do this
      || ((pkg.meta ? teams) && pkg.meta.teams == [lib.teams.cuda]);
    config.allowlistedLicenses = [lib.licenses.nvidiaCuda];
  };

  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  recursivelyImport = import ./recursivelyImport.nix {inherit lib;};

  specialArgs = {
    inherit sources;
    baseVars.username = "coca";
  };
in {
  nicetop = nixosSystem {
    inherit pkgs;

    specialArgs =
      specialArgs
      // {
        hostVars = {
          hostname = "nicetop";
          timezone = "Europe/London";
          stateVersion = "25.11";
          hmStateVersion = "23.11";
        };
      };

    modules = recursivelyImport [
      ./base
      ./graphical
      ./hosts/nicetop
    ];
  };
}
