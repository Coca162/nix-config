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

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    use-xdg-base-directories = true;
    trusted-users = ["@wheel"];
    keep-going = true;

    # Keeps the compiled build outputs, means we don't have to rebuild everything again after gc
    keep-outputs = true;
    keep-derivations = true;

    extra-substituters = ["https://afnix-hydra.s3-bulk-web.afnix.fr?priority=50"];
    extra-trusted-public-keys = ["afnix:oqt801y+IwJ09XRtNDQYCKb7zuCw9DQXQk8fDWPkwxM"];
  };

  system.stateVersion = hostVars.stateVersion;
}
