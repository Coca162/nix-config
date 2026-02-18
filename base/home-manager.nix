{
  lib,
  sources,
  baseVars,
  hostVars,
  ...
}: {
  imports = [
    "${sources.home-manager}/nixos"

    # Let us use hm as shorthand for home-manager config
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" baseVars.username])
  ];

  home-manager.useGlobalPkgs = true;

  # The home.stateVersion option does not have a default and must be set, DO NOT CHANGE WITHOUT CARE
  hm.home.stateVersion = hostVars.hmStateVersion;
}
