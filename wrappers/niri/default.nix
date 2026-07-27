_: {
  options.configFile.default = builtins.toString ./config.kdl;

  options.package.defaultFunc = {inputs}: let
    inherit (inputs.nixpkgs.pkgs) niri libdisplay-info fetchFromGitLab;
  in
    niri.override {
      libdisplay-info = libdisplay-info.overrideAttrs (finalAttrs: {
        version = "0.3.0";
        src = fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "emersion";
          repo = "libdisplay-info";
          rev = finalAttrs.version;
          sha256 = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
        };
      });
    };
}
