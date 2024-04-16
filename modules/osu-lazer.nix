{
  config,
  lib,
  pkgs,
  nix-gaming ? null,
  ...
}:
if nix-gaming != null
then {
  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  environment.systemPackages = [
    nix-gaming.packages.${pkgs.system}.osu-lazer-bin
  ];
}
else {}
