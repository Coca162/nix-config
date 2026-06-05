{
  sources ? import ../npins,
  pkgs ? import sources.nixpkgs {overlays = [(import ../packages)];},
  config ? {},
}: let
  adios = import "${sources.adios}/adios";
  adios-wrappers = import sources.adios-wrappers {adios = sources.adios;};

  extra-modules = adios.lib.importModules ./modules;

  overrides = adios.lib.importModules (pkgs.lib.fileset.toSource {
    root = ./.;
    fileset = pkgs.lib.fileset.difference ./. ./modules;
  });
  root = {
    name = "root";
    modules = pkgs.lib.recursiveUpdate (adios-wrappers // extra-modules) overrides;
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
