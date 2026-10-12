let
  sources = import ./npins;

  lib = import "${sources.nixpkgs}/lib";
  inherit (lib) getName teams licenses;

  pkgs = import sources.nixpkgs {
    overlays = [
      (import "${sources.lix}/nix-support/build/overlay.nix" {
        inherit lib;
        versionSuffix = "-${builtins.substring 0 7 sources.lix.revision}";
        officialRelease = false;
        nix_2_18 = null;
      } (p: p.clangStdenv))
    ];

    config.allowUnfreePredicate = pkg:
      builtins.elem (getName pkg) [
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
      || ((pkg.meta ? teams) && pkg.meta.teams == [teams.cuda]);
    config.allowlistedLicenses = [licenses.nvidiaCuda];
  };

  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  recursivelyImport = import ./recursivelyImport.nix {inherit lib;};

  mkWrappers = config:
    import ./wrappers {
      inherit pkgs config sources;
    };

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
          timezone = "Europe/Sofia";
          stateVersion = "25.11";
        };
        wrappers = mkWrappers {nvidia = true;};
      };

    modules = recursivelyImport [
      ./base
      ./graphical
      ./hosts/nicetop
    ];
  };
}
