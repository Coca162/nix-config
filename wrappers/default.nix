{
  sources ? import ../npins,
  pkgs ? import sources.nixpkgs {overlays = [(import ../packages)];},
  config ? {},
}: let
  adios = import "${sources.adios}/adios";
  adios-wrappers = import sources.adios-wrappers {inherit adios;};

  root = {
    modules = adios.lib.inject [
      adios-wrappers
      (adios.lib.importModules {directory = ./modules;})
      (adios.lib.importModules {directory = ./.;})
    ];
  };

  wrapperModules = adios root {
    options = {
      "/nixpkgs" = {
        inherit pkgs;
      };
      "/config" = config;
    };
  };
in
  builtins.mapAttrs (_: module: module {}) wrapperModules.modules
