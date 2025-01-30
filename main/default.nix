{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  fileSystems."/home/coca" = {
    device = "/dev/disk/by-uuid/a0e08bb3-18b0-4ee8-a402-0e00f9220a68";
    fsType = "btrfs";
    options = ["subvol=nixos-home"];
  };

  networking.hostName = "nixos"; # Define your hostname.

  time.timeZone = "Europe/Sofia";

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  users.users.coca.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbKRrvV2yAvqGGMb314npHVbof1wy20ZrIxYXDPmgoD"
  ];
  services.fail2ban = {
    enable = true;
    maxretry = 4;
    bantime-increment.enable = true;
  };

  environment.systemPackages = with pkgs; [nvtopPackages.nvidia virtiofsd];

  # Cuda
  nixpkgs.config.cudaSupport = true;
  nixpkgs.overlays = [
    (final: prev: let
      untuned-pkgs = import pkgs.path {
        system = "x86_64-linux";
      };
    in {
      # Software not worth compiling for cuda
      inherit (untuned-pkgs) blender krita gimp;
    })
  ];

  boot.kernel.sysctl = {
    # Networking
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.core.wmem_max" = 838900000; # 0.1 GiB
    "net.core.rmem_max" = 838900000; # 0.1 GiB
    "net.ipv4.tcp_rmem" = "4096 87380 838900000"; # 0.1 GiB max
    "net.ipv4.tcp_wmem" = "4096 87380 838900000"; # 0.1 GiB max
  };

  # TODO: add quickemu
  virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;
  programs.virt-manager.enable = true;
  boot.kernelModules = ["kvm-amd" "kvm-intel"];

  hardware.opentabletdriver.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Enables proprietary drivers
    modesetting.enable = true;

    # Open is the new default for 560 (beta) drivers
    open = true;

    # Enables settings gui which barely works
    nvidiaSettings = false;

    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
