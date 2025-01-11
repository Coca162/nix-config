{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos"; # Define your hostname.

  time.timeZone = "Europe/Sofia";

  environment.systemPackages = with pkgs; [nvtopPackages.nvidia virtiofsd];

  services.mediawiki = let
    old_pkg =
      import (builtins.fetchTarball {
        name = "nixpkg-working-mediawiki";
        url = "https://github.com/nixos/nixpkgs/archive/571c71e6f73af34a229414f51585738894211408.tar.gz";
        sha256 = "0fgp5sqfmh5zgx75rs5101ywkz0fkjff67abms0kc8hyaxmlc7js";
      }) {
        system = "x86_64-linux";
      };
  in {
    enable = true;
    package = old_pkg.mediawiki;
    name = "Sample MediaWiki";
    httpd.virtualHost = {
      hostName = "localhost";
      adminAddr = "admin@example.com";
    };
    passwordFile = pkgs.writeText "password" "cardbotnine";

    extraConfig = ''
      $wgMaxUploadSize = 1000000000;
      $wgAllowCopyUploads = true;
      $wgScribuntoEngineConf['luastandalone']['luaPath'] = '${pkgs.lua51Packages.lua}/bin/lua';
    '';

    extensions = {
      VisualEditor = null;

      PortableInfobox = pkgs.fetchzip {
        url = "https://github.com/Universal-Omega/PortableInfobox/archive/f5780412fcb25d3981cdc7f2af8f75518d9ee3cb.zip";
        hash = "sha256-Hm1+jzhq+PIx699ICgJM92xt6UW8jko+kxT2icdCDFc=";
      };

      Scribunto = pkgs.fetchzip {
        url = "https://extdist.wmflabs.org/dist/extensions/Scribunto-REL1_42-9c46437.tar.gz";
        hash = "sha256-oX4FOAJqe6G7AzxcT2ANsxoA93M6JSl/O+kudi/LQUA=";
      };

      Capiunto = pkgs.fetchzip {
        url = "https://extdist.wmflabs.org/dist/extensions/Capiunto-REL1_42-77ccef8.tar.gz";
        hash = "sha256-wKRqzbFSiB9xZmz293S1gYUtQyax/ikxWVc0+gjwCdY=";
      };

      TabberNeue = pkgs.fetchzip {
        url = "https://github.com/StarCitizenTools/mediawiki-extensions-TabberNeue/archive/a003ee0787bd9033498caf933aaf8c1acde64489.zip";
        hash = "sha256-INqaJhKIyci1NiI6GAiP1QXHHtkwGjV9jtFpGunP8Fc=";
      };

      Array = pkgs.fetchzip {
        url = "https://extdist.wmflabs.org/dist/extensions/Arrays-REL1_42-41a1be4.tar.gz";
        hash = "sha256-8GnG6u4jpA6PpYe1rT5uPKtW33E7LhTvi9bWbJFyjR4=";
      };
    };
  };

  services.phpfpm.pools.mediawiki.phpOptions = ''
    upload_max_filesize = 150000M
    post_max_size = 1500000M
  '';

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
