{
  pkgs,
  callPackage,
}: rec {
  spawn-terminal = import ./spawn-terminal.nix pkgs;

  scripts = [spawn-terminal];

  thumbfast-osc = import ./thumbfast-osc.nix pkgs;
}
