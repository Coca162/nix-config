let
  sources = import ./npins;

  lib = import "${sources.nixpkgs}/lib";
  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  recursivelyImport = import ./recursivelyImport.nix {inherit lib;};

  specialArgs = {
    inherit sources;
    baseVars.username = "coca";
  };
in {
  nicetop = nixosSystem {
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
