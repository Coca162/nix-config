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
          lix = pkgs.applyPatches {
            name = "lix-main-patched";
            src = lix.outPath;
            patches = [
              ./0001-bindings-linear-search-small-sets.patch
              ./0002-primops-o1-tail-share-elems.patch
              (pkgs.fetchpatch2 {
                name = "lix-replxx-5.patch";
                url = "https://gerrit.lix.systems/changes/lix~5534/revisions/5/patch?download&raw";
                hash = "sha256-BJ2fsO8rjbcOUw//dCAAc0zcSpLA6mxy4MG3uaBD1Rc=";
              })
            ];
          };
          versionSuffix = "-${builtins.substring 0 8 lix.revision}-raf-patched";
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
