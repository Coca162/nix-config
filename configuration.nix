# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
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

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "16384";
    }
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  virtualisation.libvirtd.enable = true;
  boot.kernelModules = ["kvm-amd" "kvm-intel"];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/boot".options = ["umask=0077"]; # Make random seed file not world accessible

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "vm.swappiness" = 2;

    # Networking
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.core.wmem_max" = 838900000; # 0.1 GiB
    "net.core.rmem_max" = 838900000; # 0.1 GiB
    "net.ipv4.tcp_rmem" = "4096 87380 838900000"; # 0.1 GiB max
    "net.ipv4.tcp_wmem" = "4096 87380 838900000"; # 0.1 GiB max
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "nixos";

  time.timeZone = "Europe/Sofia";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "bg_BG.UTF-8"; # Imperial metrics?! Couldn't be me.
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  sound.enable = true;

  hardware.pulseaudio.enable = lib.mkForce false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.coca = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  users.users.testing = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    gparted
    qdirstat
    kate
    osu-lazer-bin
    bitwig-studio
    pinta
    gimp
    krita
    inkscape
    prismlauncher
    qbittorrent
    qt6.qtimageformats
    wl-clipboard-rs
    nvd
    nix-output-monitor
    cargo
  ];

  programs.fish.enable = true;

  programs.kdeconnect.enable = true;

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
  services.dbus.packages = [pkgs.pinentry-qt];

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.cudaSupport = true; # On unstable this recompiles way too much

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [5201];
  #   allowedUDPPorts = [5201];

  #   allowedTCPPortRanges = [
  #     {
  #       from = 7000;
  #       to = 7999;
  #     }
  #   ];

  #   allowedUDPPortRanges = [
  #     {
  #       from = 7000;
  #       to = 7999;
  #     }
  #   ];
  # };

  programs.coolercontrol = {
    enable = true;
    nvidiaSupport = true;
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
