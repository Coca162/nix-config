final: prev: {
  spawn-terminal = import ./spawn-terminal.nix final.pkgs;

  mpvScripts = prev.mpvScripts.overrideScope (mfinal: mprev: {
    thumbfast-osc = import ./thumbfast-osc.nix final.pkgs;
  });

  space-station-14-launcher = let
    src = final.fetchFromGitHub {
      owner = "space-wizards";
      repo = "SS14.Launcher";
      rev = "de91b7e9051debca9ddfcdb2c7b8d2af900ebb23";
      hash = "sha256-NW7bTP0IEwjZ60LBhmWlAOChFJHn5tBLdg+wquqCGmI=";
      fetchSubmodules = true;
    };
  in
    (final.callPackage "${src}/nix/package.nix" {}).overrideAttrs {inherit src;};
}
