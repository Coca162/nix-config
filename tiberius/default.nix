{...}: {
  imports = [
    ../configuration.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "tiberius"; # Define your hostname.

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

  boot.kernel.sysctl = {
    # Networking
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.core.wmem_max" = 838900000; # 0.1 GiB
    "net.core.rmem_max" = 838900000; # 0.1 GiB
    "net.ipv4.tcp_rmem" = "4096 87380 838900000"; # 0.1 GiB max
    "net.ipv4.tcp_wmem" = "4096 87380 838900000"; # 0.1 GiB max
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
