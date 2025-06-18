{
  pkgs,
  callPackage,
}: rec {
  spawn-terminal = import ./spawn-terminal.nix pkgs;
  vod-stats = callPackage ./vod-stats.nix {};

  scripts = [spawn-terminal vod-stats];

  thumbfast-osc = import ./thumbfast-osc.nix pkgs;
}
