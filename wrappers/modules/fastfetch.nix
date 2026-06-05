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
      description = "The fastfetch package to be wrapped.";
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.fastfetch;
    };
  };

  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs.pkgs) writeText;
    inherit (inputs.nixpkgs.lib.generators) toJSON;
  in
    assert !(options ? settings && options ? settingsFile);
      inputs.mkWrapper {
        inherit (options) package;

        symlinks = {
          "$out/fastfetch/config.jsonc" =
            if options ? settingsFile
            then options.settingsFile
            else if options ? settings
            then writeText "config.jsonc" (toJSON {} options.settings)
            else null;
        };

        flags = [
          "--config"
          "$out/fastfetch/config.jsonc"
        ];
      };
}
