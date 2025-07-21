{
  pkgs,
  lib,
  ...
}: let
  sources = import ./npins;
in {
  imports = [
    "${sources.home-manager}/nixos"
    # (import "${sources.lix-module}/module.nix" {inherit (sources) lix;})
  ];

  nixpkgs.overlays = [
    (final: prev: let
      versionSuffix = "-horribly-patched";
      lix = final.applyPatches {
        name = "lix${versionSuffix}";
        src = sources.lix;
        patches = [
          (final.fetchpatch {
            name = "lix-2.93-structuredAttrs.patch";
            url = "https://gerrit.lix.systems/changes/lix~3668/revisions/2/patch?download&raw";
            hash = "sha256-JQlAU0texMa7DMrqk447SXJUEu1k4IP9z8mjCHyskVc=";
          })
        ];
      };
      patchedOverlay = import (sources.lix-module + "/overlay.nix") {
        inherit versionSuffix lix;
      };
    in
      patchedOverlay final prev)
  ];

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
    delta
    rescrobbled
    (lib.hiPrio pkgs.uutils-coreutils-noprefix)
  ];

  environment.shellAliases.unpins = lib.getExe (import sources.unpins {});

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
    || ((pkg.meta ? teams) && pkg.meta.teams == [pkgs.lib.teams.cuda]);

  nixpkgs.config.allowlistedLicenses = with lib.licenses; [nvidiaCuda];

  nix.extraOptions = ''
    trusted-users = @wheel
    # Keeps the compiled build outputs, means we don't have to rebuild everything again after gc
    keep-outputs = true
    keep-derivations = true
  '';

  system.rebuild.enableNg = true;

  systemd.user.services.scrobbler = {
    description = "An MPRIS scrobbler";
    documentation = ["https://github.com/InputUsername/rescrobbled"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    unitConfig.ConditionUser = "coca";
    serviceConfig.ExecStart = lib.getExe pkgs.rescrobbled;
    wantedBy = ["default.target"];
  };
}
