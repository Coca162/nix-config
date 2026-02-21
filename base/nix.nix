{
  pkgs,
  lib,
  sources,
  hostVars,
  ...
}: {
  # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this config.
  nix.registry.nixpkgs.flake = sources.nixpkgs;

  # remove nix-channel related tools & configs, we use system-wide pinned paths instead.
  nix.channel.enable = false;
  environment.etc = {
    "nixos/nixpkgs".source = builtins.storePath pkgs.path;
    "nixos/rust-overlay".source = sources.rust-overlay;
  };
  nix.nixPath = [
    "nixpkgs=/etc/nixos/nixpkgs"
    "rust-overlay=/etc/nixos/rust-overlay"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.use-xdg-base-directories = true;

  nix.package = pkgs.lixPackageSets.latest.lix;

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

  system.stateVersion = hostVars.stateVersion;
}
