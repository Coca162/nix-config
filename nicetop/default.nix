{
  config,
  pkgs,
  lib,
  sources,
  ...
}: let
  diski = import sources.diski {inherit pkgs;};
in {
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
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="a0e08bb3-18b0-4ee8-a402-0e00f9220a68", ENV{UDISKS_IGNORE}="1", ENV{SYSTEMD_USER_WANTS}+="disk_status_external.service"
  '';

  systemd.automounts = [
    {
      description = "Automount for btrfs 2TB external drive";
      where = "/data/btrfs-external";
      wantedBy = ["multi-user.target"];
      automountConfig.TimeoutIdleSec = 5;
    }
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id != "org.freedesktop.systemd1.manage-units" || subject.user != "coca") {
            return;
        }

        const unit = action.lookup("unit");
        if (unit != "data-btrfs\\x2dexternal.automount" && unit != "data-btrfs\\x2dexternal.mount") {
            return;
        }

        const verb = action.lookup("verb");
        if (verb == "start" || verb == "stop" || verb == "restart") {
            return polkit.Result.YES;
        }
    });
  '';

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [virtiofsd];
  };
  # virtualisation.spiceUSBRedirection.enable = true;

  users.users.coca.extraGroups = ["networkmanager"];

  networking.hostName = "nicetop"; # Define your hostname.

  time.timeZone = "Europe/London";

  services.thermald.enable = true;

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    quickemu
  ];

  services.xserver.videoDrivers = ["nvidia"];

  # For when the beta drivers are broken with the later kernel version
  # https://www.nvidia.com/en-us/drivers/unix/
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
  #   version = "580.119.02"; # Copy the version number here
  #   sha256_64bit = "sha256-gCD139PuiK7no4mQ0MPSr+VHUemhcLqerdfqZwE47Nc="; # "Cannot build "/nix/store/*-nvidia-x11-*"
  #   sha256_aarch64 = "";
  #   openSha256 = "sha256-l3IQDoopOt0n0+Ig+Ee3AOcFCGJXhbH1Q1nh1TEAHTE="; # "Cannot build "/nix/store/*-nvidia-open-*"
  #   settingsSha256 = "sha256-sI/ly6gNaUw0QZFWWkMbrkSstzf0hvcdSaogTUoTecI="; # "Cannot build "/nix/store/*-nvidia-settings-*"
  #   persistencedSha256 = "";
  # };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # Enables proprietary drivers
    modesetting.enable = true;
    open = true;
    # powerManagement.enable = true; Try when on the go

    # Half broken stuff
    nvidiaSettings = false;
    videoAcceleration = false;
  };

  hardware.graphics.extraPackages = [pkgs.intel-media-driver];
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
