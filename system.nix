let
  sources = import ./npins;

  pkgs = let
    inherit (pkgs.lib) getName teams licenses;
    lix = sources.lix;
  in
    import sources.nixpkgs {
      overlays = [
        (import "${sources.lix-module}/overlay.nix" {
          lix = {
            inherit (lix) outPath;
            rev = lix.revision;
          };
          versionSuffix = "-${builtins.substring 0 7 lix.revision}";
        })
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
  recursivelyImport = import ./recursivelyImport.nix {inherit (pkgs) lib;};

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
          timezone = "Europe/London";
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
