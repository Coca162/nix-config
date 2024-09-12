{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  # WHY GOD WHY DOES PULSEAUDIO WORK BUT NOT PIPEWIRE
  services.pipewire.enable = lib.mkForce false;
  hardware.pulseaudio.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.coca.extraGroups = ["networkmanager"];

  networking.hostName = "nicetop"; # Define your hostname.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
