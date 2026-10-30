{
  sources ? import ../npins,
  pkgs ? import sources.nixpkgs {},
  config ? {},
}: let
  adios = import sources.adios;
  adios-wrappers = import sources.adios-wrappers {inherit adios;};

  root = {
    modules = adios.lib.inject [
      adios-wrappers
      (adios.lib.importModules {directory = ./modules;})
      (adios.lib.importModules {directory = ./.;})
      {
        nixpkgs.options.pkgs.default = pkgs;
        config.options = builtins.mapAttrs (_: value: {default = value;}) config;
      }
    ];
  };

  tree = adios.eval {inherit root;};
in
  builtins.mapAttrs (_: module: module {}) tree.modules
