final: prev: {
  spawn-terminal = import ./spawn-terminal.nix final.pkgs;

  mpvScripts = prev.mpvScripts.overrideScope (mfinal: mprev: {
    thumbfast-osc = import ./thumbfast-osc.nix final.pkgs;
  });

  rescrobbled = prev.rescrobbled.overrideAttrs (old: {
    version = "auto-reconnect";
    src = final.fetchFromGitHub {
      owner = "marius851000";
      repo = "rescrobbled";
      rev = "1fc643b888c8ad2eb46c53a25b6f8f1da4f38b3d";
      hash = "sha256-OXLJvPwEWqrzRdEZlBv6eb3TfVaA7ujbAAoeFq2BHK4=";
    };
  });
}
