{types, ...}: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    settings = {
      type = types.attrs;
      description = ''
        Settings to be injected into the wrapped package's `config.yml`.

        See the documentation:
        https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md

        Disjoint with the `configFile` option.
      '';
    };
    configFile = {
      type = types.pathLike;
      description = ''
        `config.yml` file to be injected into the wrapped package.

        See the documentation for syntax and valid options:
        https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md

        Disjoint with the `settings` option.
      '';
    };

    package = {
      type = types.derivation;
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.lazygit;
      description = "The lazygit package to be wrapped.";
    };
  };

  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs.pkgs) formats;
    generator = formats.yaml {};
  in
    assert options ? settings != options ? configFile;
      inputs.mkWrapper {
        inherit (options) package;
        symlinks = {
          "$out/lazygit/config.yml" =
            if options ? configFile
            then options.configFile
            else generator.generate "config.yml" options.settings;
        };
        environment = {
          LG_CONFIG_FILE = "$out/lazygit/config.yml";
        };
      };

  meta = {
    maintainers = ["coca"];
  };
}
