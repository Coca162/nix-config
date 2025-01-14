# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  pkgs,
  lib,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.tools.nixos-option.enable = false; # Complains about Lix or something

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/boot".options = ["umask=0077"]; # Make random seed file not world accessible

  boot.supportedFilesystems = ["ntfs"];
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

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
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
    waypipe
    sshfs
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
      aliases.url = {
        "https://codeberg.org/".insteadOf = ["cb:" "codeberg:"];
        "https://github.com/".insteadOf = ["gh:" "github:"];
        "https://gitlab.com/".insteadOf = ["gl:" "gitlab:"];
        "https://git.lix.systems/".insteadOf = "lix:";
        "https://git.coca.codes/".insteadOf = "coca:";
      };
    };
  };

  programs.ssh.enableAskPassword = true;
  programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
  environment.variables = {
    SSH_ASKPASS_REQUIRE = "prefer";
    MANPAGER = "${lib.getExe pkgs.bat} --wrap=auto --language=man --plain --strip-ansi=auto";
  };

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
