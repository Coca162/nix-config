let
  sources = import ./npins;

  pkgs = let
    inherit (pkgs.lib) getName teams licenses;
    lix-module = sources.lix-module;
    lix = sources.lix {inherit pkgs;};
  in
    import sources.nixpkgs {
      overlays = [
        (import ./packages)
        (import "${lix-module}/overlay.nix" {
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
        # TODO: Find a better way to do this
        || ((pkg.meta ? teams) && pkg.meta.teams == [teams.cuda]);
      config.allowlistedLicenses = [licenses.nvidiaCuda];
    };

  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  recursivelyImport = import ./recursivelyImport.nix {inherit (pkgs) lib;};

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
