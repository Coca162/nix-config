{...}: {
  hardware.bluetooth.enable = true;

  # Prevent overheating
  services.thermald.enable = true;

  # For balancing power usage, should not conflict with thermald hopefully
  services.tlp = {
    enable = true;
    pd.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # We have zswap and 32GB of ram on here it'll be fine
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "75%";
}
