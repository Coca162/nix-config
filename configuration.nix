# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  lib,
  untuned-pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      # opencv fails and I need to fucking do this shit to make it work
      # https://github.com/NixOS/nixpkgs/issues/338315
      inherit (untuned-pkgs) glaxnimate mlt frei0r;

      # Software not worth compiling for cuda
      inherit (untuned-pkgs) blender;

      # Libraries not worth compiling for cuda
      inherit (untuned-pkgs) webkitgtk electron electron_31;

      # Gets very grumpy compiling under znver2 and x86-64-v3
      embree = prev.embree.overrideAttrs {
        NIX_CFLAGS_COMPILE = "-march=x86-64-v2";
      };

      opencolorio = prev.opencolorio.overrideAttrs {
        NIX_CFLAGS_COMPILE = "-march=x86-64-v2";
      };

      haskellPackages = prev.haskellPackages.override {
        overrides = finalHaskell: prevHaskell: {
          crypton = prevHaskell.crypton.overrideAttrs {
            NIX_CFLAGS_COMPILE = "-march=x86-64-v2";
          };
        };
      };

      # Test is fine to skip https://gitlab.com/inkscape/lib2geom/-/issues/63
      lib2geom = prev.lib2geom.overrideAttrs {
        checkPhase = let
          disabledTests = ["elliptical-arc-test"];
        in ''
          runHook preCheck
          ctest --output-on-failure -E '^${lib.concatStringsSep "|" disabledTests}$'
          runHook postCheck
        '';
      };

      # From searching people have disabled this one without issues
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
        ++ [
          (pyfinal: pyprev: {
            numpy = pyprev.numpy.overridePythonAttrs (oldAttrs: {
              disabledTests = [
                "test_validate_transcendentals"
              ];
            });
          })
        ];
    })
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  boot.kernelModules = ["kvm-amd" "kvm-intel"];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/boot".options = ["umask=0077"]; # Make random seed file not world accessible

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "vm.swappiness" = 5;

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
  environment.plasma6.excludePackages = [pkgs.kdePackages.elisa];
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
    kdePackages.kdenlive
    inkscape
    prismlauncher
    qbittorrent
    qt6.qtimageformats
    wl-clipboard-rs
    nvd
    nix-output-monitor
    aseprite
    obs-studio
    lsof
    fatrace
    nvtopPackages.nvidia
    google-fonts # EVER FONT IN EXISTENCE!!!
    blender
    bitwarden-desktop
    obsidian
  ];

  programs.fish.enable = true;

  programs.kdeconnect.enable = true;

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
  services.dbus.packages = [pkgs.pinentry-qt];
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      aliases = {
        url = {
          "https://codeberg.org/".insteadOf = ["cb:" "codeberg:"];
          "https://github.com/".insteadOf = ["gh:" "github:"];
          "https://gitlab.com/".insteadOf = ["gl:" "gitlab:"];
          "https://git.lix.systems/".insteadOf = "lix:";
        };
      };
    };
  };

  programs.ssh.enableAskPassword = true;
  programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
  environment.variables.SSH_ASKPASS_REQUIRE = "prefer";

  programs.steam.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  nix.settings.system-features = ["benchmark" "big-parallel" "kvm" "nixos-test" "gccarch-znver2"];

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  ''; # Keeps the compiled build outputs, means we don't have to rebuild everything again after gc

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.opentabletdriver.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Enables proprietary drivers
    modesetting.enable = true;

    # Open is the new default for 560 (beta) drivers
    open = true;

    # Enables nvidia-settings which barely works
    nvidiaSettings = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
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
