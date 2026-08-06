{
  pkgs,
  lib,
  ...
}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
  };

  systemd.targets.postgresql.wantedBy = lib.mkForce [];
}
