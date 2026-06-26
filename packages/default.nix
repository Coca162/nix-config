final: prev: {
  spawn-terminal = import ./spawn-terminal.nix final.pkgs;

  mpvScripts = prev.mpvScripts.overrideScope (mfinal: mprev: {
    thumbfast-osc = import ./thumbfast-osc.nix final.pkgs;
  });
}
