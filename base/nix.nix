{
  pkgs,
  sources,
  hostVars,
  ...
}: {
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

  # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by nixos.
  nix.registry.nixpkgs.flake = sources.nixpkgs;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.use-xdg-base-directories = true;
  nix.settings.trusted-users = ["@wheel"];

  nix.extraOptions = ''
    # Keeps the compiled build outputs, means we don't have to rebuild everything again after gc
    keep-outputs = true
    keep-derivations = true
  '';

  system.stateVersion = hostVars.stateVersion;
}
