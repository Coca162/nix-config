# Micro mutates its config dir so this isn't really useful yet
# https://github.com/micro-editor/micro/issues/2004
{types, ...}: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    settings = {
      type = types.attrs;
    };
    configFile = {
      type = types.pathLike;
    };

    bindings = {
      type = types.attrs;
    };
    bindingsFile = {
      type = types.pathLike;
    };

    package = {
      type = types.derivation;
      description = "The micro package to be wrapped.";
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.micro;
    };
  };

  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs.pkgs) writeText;
    inherit (inputs.nixpkgs.lib.generators) toJSON;
  in
    assert !(options ? settings && options ? configFile);
    assert !(options ? bindings && options ? bindingsFile);
      inputs.mkWrapper {
        inherit (options) package;

        symlinks = {
          "$out/micro/settings.json" =
            if options ? configFile
            then options.configFile
            else if options ? settings
            then writeText "settings.json" (toJSON {} options.settings)
            else null;

          "$out/micro/bindings.json" =
            if options ? bindingsFile
            then options.bindingsFile
            else if options ? bindings
            then writeText "bindings.json" (toJSON {} options.bindings)
            else null;
        };

        environment = {
          MICRO_CONFIG_HOME = "$out/micro";
        };
      };

  meta = {
    maintainers = ["coca"];
  };
}
