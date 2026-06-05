{types, ...}: {
  inputs = {
    mkWrapper.path = "/mkWrapper";
    nixpkgs.path = "/nixpkgs";
  };

  options = {
    settings = {
      type = types.attrs;
    };
    settingsFile = {
      type = types.pathLike;
    };

    inputs = {
      type = types.attrs;
    };
    inputsFile = {
      type = types.pathLike;
    };

    package = {
      type = types.derivation;
      description = "The mpv package to be wrapped.";
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.mpv;
    };
  };

  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs.pkgs) writeText;
    inherit (inputs.nixpkgs.lib) generators concatStringsSep mapAttrsToList;
    inherit (builtins) typeOf stringLength;

    # Most of this copied from https://github.com/nix-community/home-manager/blob/master/modules/programs/mpv.nix

    renderOption = option:
      rec {
        int = toString option;
        float = int;
        bool =
          if option
          then "yes"
          else "no";
        string = option;
      }
    .${
        typeOf option
      };

    renderOptionValue = value: let
      rendered = renderOption value;
      length = toString (stringLength rendered);
    in "%${length}%${rendered}";

    renderOptions = generators.toKeyValue {
      mkKeyValue = generators.mkKeyValueDefault {mkValueString = renderOptionValue;} "=";
      listsAsDuplicateKeys = true;
    };

    renderBindings = bindings: concatStringsSep "\n" (mapAttrsToList (name: value: "${name} ${value}") bindings);
  in
    assert !(options ? settings && options ? settingsFile);
    assert !(options ? inputs && options ? inputsFile);
      inputs.mkWrapper {
        inherit (options) package;

        name = "mpv";

        symlinks = {
          "$out/mpv/mpv.conf" =
            if options ? settingsFile
            then options.settingsFile
            else if options ? settings
            then writeText "mpv.conf" (renderOptions options.settings)
            else null;

          "$out/mpv/input.conf" =
            if options ? inputsFile
            then options.inputsFile
            else if options ? inputs
            then writeText "input.conf" (renderBindings options.inputs)
            else null;
        };

        environment = {
          XDG_CONFIG_HOME = "$out";
        };
      };
}
