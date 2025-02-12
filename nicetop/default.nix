{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../configuration.nix
    ../graphical.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/boot".options = ["umask=0077"]; # Make random seed file not world accessible

  systemd.mounts = [
    {
      description = "Mount for btrfs 2TB external drive";
      what = "/dev/disk/by-uuid/a0e08bb3-18b0-4ee8-a402-0e00f9220a68";
      where = "/data/btrfs-external";
      type = "btrfs";
      options = "defaults,rw";
    }
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="block", ENV{ID_FS_UUID}=="a0e08bb3-18b0-4ee8-a402-0e00f9220a68", ENV{UDISKS_IGNORE}="1"
  '';

  systemd.automounts = [
    {
      description = "Automount for btrfs 2TB external drive";
      where = "/data/btrfs-external";
      wantedBy = ["multi-user.target"];
      automountConfig.TimeoutIdleSec = 10;
    }
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.coca.extraGroups = ["networkmanager"];

  networking.hostName = "nicetop"; # Define your hostname.

  time.timeZone = "Europe/London";

  services.thermald.enable = true;

  environment.systemPackages = with pkgs; [nvtopPackages.nvidia];

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Enables proprietary drivers
    modesetting.enable = true;

    # Open is the new default for 560 (beta) drivers
    open = false;

    # Enables settings gui which barely works
    nvidiaSettings = false;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };

    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
