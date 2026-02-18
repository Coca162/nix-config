{...}: {
  hardware.bluetooth.enable = true;

  services.thermald.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_16;
  #   extensions = [
  #     (import (fetchTarball "https://github.com/Coca162/nixpkgs/archive/afc3b6816cb1fc42887f6ed94bb50b60f6741ac3.tar.gz") {}).postgresql16Packages.pg-uint128
  #   ];
  # };
}
