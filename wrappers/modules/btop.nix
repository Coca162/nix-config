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

    package = {
      type = types.derivation;
      description = "The btop package to be wrapped.";
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.btop;
    };
  };

  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs.pkgs) writeText;
    inherit (inputs.nixpkgs.lib) generators;

    # Mostly copied from home-manager
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/mpv.nix
    toKeyValue = generators.toKeyValue {
      mkKeyValue = generators.mkKeyValueDefault {
        mkValueString = v: let
          inherit (builtins) isBool isString;
        in
          if isBool v
          then
            (
              if v
              then "True"
              else "False"
            )
          else if isString v
          then ''"${v}"''
          else toString v;
      } " = ";
    };
  in
    assert !(options ? settings && options ? settingsFile);
      inputs.mkWrapper {
        inherit (options) package;

        symlinks = {
          "$out/btop/btop.conf" =
            if options ? settingsFile
            then options.settingsFile
            else if options ? settings
            then writeText "btop.conf" (toKeyValue options.settings)
            else null;
        };

        flags = [
          "--config"
          "$out/btop/btop.conf"
        ];
      };
}
