{types, ...}: {
  inputs = {
    mkWrapper.path = "/mkWrapper";
    nixpkgs.path = "/nixpkgs";
  };

  options = {
    configFile = {
      type = types.pathLike;
    };

    package = {
      type = types.derivation;
      description = "The niri package to be wrapped.";
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.niri;
    };
  };

  impl = {
    options,
    inputs,
  }:
    if options ? configFile
    then
      inputs.mkWrapper {
        inherit (options) package;
        environment = {
          NIRI_CONFIG = options.configFile;
        };
      }
    else options.package;
}
