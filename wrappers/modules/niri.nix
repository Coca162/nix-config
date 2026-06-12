{types, ...}: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
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
        # hack gotten from https://github.com/Lassulus/wrappers/blob/main/modules/niri/module.nix
        postWrap = ''
          cp $out/share/systemd/user/niri.service niri.service
          chmod +w niri.service
          cat >> niri.service<<EOF
          [Service]
          ExecStart=
          ExecStart=$out/bin/niri --session
          EOF
          cp --remove-destination niri.service $out/share/systemd/user/niri.service
        '';
        environment = {
          NIRI_CONFIG = options.configFile;
        };
      }
    else options.package;

  meta = {
    maintainers = ["coca"];
  };
}
