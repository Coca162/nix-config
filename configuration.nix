{
  pkgs,
  lib,
  ...
}: let
  sources = import ./npins;
in {
  imports = [
    "${sources.home-manager}/nixos"
    (import "${sources.lix-module}/module.nix" {inherit (sources) lix;})
  ];

  _module.args = {inherit sources;};

  # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this config.
  nix.registry.nixpkgs.flake = sources.nixpkgs;

  # remove nix-channel related tools & configs, we use system-wide npins instead.
  nix.channel.enable = false;
  nix.nixPath = [
    "nixpkgs=${sources.nixpkgs}"
    "rust-overlay=${sources.rust-overlay}"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.tools.nixos-option.enable = false; # Complains about Lix or something

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.coca = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.coca = lib.mkDefault (import ./home.nix);

  environment.systemPackages = with pkgs; [
    wl-clipboard-rs
    nvd
    nix-output-monitor
    lsof
    fatrace
    waypipe
    sshfs
    btrfs-progs
    npins
  ];

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

  programs.ssh.package = pkgs.openssh_hpn;

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
    || ((pkg.meta ? maintainers) && pkg.meta.maintainers == pkgs.lib.teams.cuda.members);

  nixpkgs.config.allowlistedLicenses = with lib.licenses; [nvidiaCuda];

  nix.extraOptions = ''
    trusted-users = @wheel
    # Keeps the compiled build outputs, means we don't have to rebuild everything again after gc
    keep-outputs = true
    keep-derivations = true
  '';

  system.rebuild.enableNg = true;

  systemd.user.services.rescrobbled = {
    description = "An MPRIS scrobbler";
    documentation = ["https://github.com/InputUsername/rescrobbled"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    unitConfig.ConditionUser = "coca";
    serviceConfig.ExecStart = lib.getExe pkgs.rescrobbled;
    wantedBy = ["default.target"];
  };
}
