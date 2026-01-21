{
  pkgs,
  lib,
  ...
}: let
  sources = import ./npins;
  rescrobbled = pkgs.rescrobbled.overrideAttrs (old: {
    version = "auto-reconnect"; # usually harmless to omit
    src = pkgs.fetchFromGitHub {
      owner = "marius851000";
      repo = "rescrobbled";
      rev = "1fc643b888c8ad2eb46c53a25b6f8f1da4f38b3d";
      hash = "sha256-OXLJvPwEWqrzRdEZlBv6eb3TfVaA7ujbAAoeFq2BHK4=";
    };
  });
in {
  imports = [
    "${sources.home-manager}/nixos"
  ];

  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (prev.lixPackageSets.latest)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix.package = pkgs.lixPackageSets.latest.lix;

  _module.args = {inherit sources;};

  # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this config.
  nix.registry.nixpkgs.flake = sources.nixpkgs;

  # remove nix-channel related tools & configs, we use system-wide npins instead.
  nix.channel.enable = false;
  nix.nixPath = [
    "nixpkgs=/etc/nixos/nixpkgs"
    "rust-overlay=/etc/nixos/rust-overlay"
  ];
  environment.etc = {
    "nixos/nixpkgs".source = builtins.storePath pkgs.path;
    "nixos/rust-overlay".source = sources.rust-overlay;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.use-xdg-base-directories = true;

  system.tools.nixos-option.enable = false; # Complains about Lix or something

  boot.supportedFilesystems = ["ntfs"];
  boot.kernel.sysctl."kernel.sysrq" = 1;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "bg_BG.UTF-8"; # Imperial metrics?! Couldn't be me.
  };

  networking.extraHosts = ''
    0.0.0.0 wplace.live
  '';

  programs.tcpdump.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.coca = {
    isNormalUser = true;
    extraGroups = ["wheel" "pcap"];
    shell = pkgs.fish;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.coca = lib.mkDefault (import ./home.nix);

  environment.systemPackages = with pkgs;
    [
      fd
      wl-clipboard-rs
      nvd
      nix-output-monitor
      lsof
      fatrace
      waypipe
      sshfs
      btrfs-progs
      (import sources.unpins {})
      nix-tree
      (lib.hiPrio uutils-coreutils-noprefix)
      (lib.hiPrio uutils-findutils)
    ]
    ++ [rescrobbled];

  security.sudo.enable = false;

  programs.fish.enable = true;
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;
  environment.variables.MANPAGER = "${lib.getExe pkgs.bat} --wrap=auto --language=man --plain --strip-ansi=auto";

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

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "osu-lazer-bin"
      "bitwig-studio-unwrapped"
      "aseprite" # Source available
      "obsidian"
      "reaper"
      "steam"
      "steam-unwrapped"
    ]
    # TODO: Find a better way to do this
    || ((pkg.meta ? teams) && pkg.meta.teams == [pkgs.lib.teams.cuda]);

  nixpkgs.config.allowlistedLicenses = with lib.licenses; [nvidiaCuda];

  nix.extraOptions = ''
    trusted-users = @wheel
    # Keeps the compiled build outputs, means we don't have to rebuild everything again after gc
    keep-outputs = true
    keep-derivations = true
  '';
}
