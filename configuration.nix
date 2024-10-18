# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  pkgs,
  lib,
  nixpkgs,
  rust-overlay,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
  nix.registry.nixpkgs.flake = nixpkgs;
  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  # Keep nixPath so we don't have to use flakes for projects
  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
    "rust-overlay=${rust-overlay}"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/boot".options = ["umask=0077"]; # Make random seed file not world accessible

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "vm.swappiness" = 5;
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;

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
  services.pipewire = lib.mkDefault {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.coca = {
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
    kdePackages.kclock
    kdePackages.kruler
    inkscape
    prismlauncher
    qbittorrent
    qt6.qtimageformats
    wl-clipboard-rs
    nvd
    nix-output-monitor
    aseprite
    obs-studio
    wayfarer # Spectacle recording is broken for regions/windows
    lsof
    fatrace
    blender
    libreoffice-qt6
    bitwarden-desktop
    obsidian
  ];

  fonts.packages = with pkgs; [
    google-fonts # EVER FONT IN EXISTENCE!!!
    cascadia-code
    monocraft
    miracode
  ];

  programs.fish.enable = true;
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

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

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  ''; # Keeps the compiled build outputs, means we don't have to rebuild everything again after gc

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
