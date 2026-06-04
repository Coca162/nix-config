{
  pkgs,
  lib,
  sources,
  ...
}: let
  versionSuffix = "-${builtins.substring 0 7 sources.lix.revision}";
  lix =
    pkgs.callPackage (sources.lix + "/package.nix")
    {
      inherit versionSuffix;
      stdenv = pkgs.clangStdenv;
    };
in {
  nix.package = lix;

  environment.systemPackages = [
    (pkgs.nix-du.override {nix = lix;})
    (pkgs.nixpkgs-review.override {
      nix = lix;
      nix-eval-jobs = pkgs.callPackage (sources.lix + "/subprojects/nix-eval-jobs/default.nix") {
        nix = lix;
        stdenv = pkgs.clangStdenv;
      };
      withSandboxSupport = true;
      withNom = true;
      withDelta = true;
      withGlow = true;
    })
    (pkgs.callPackage "${sources.unpins}/npins.nix" {
      nix-prefetch-docker = pkgs.nix-prefetch-docker.override {nix = lix;};
    })
  ];

  hm.programs.direnv.nix-direnv.package = pkgs.nix-direnv.override {nix = lix;};

  hm.programs.vscodium.profiles.default.userSettings."nix.serverPath" = lib.getExe (pkgs.nil.override {nix = lix;});

  # Has nix somewhere in there and I'd rather not deal with that rn
  documentation.nixos.enable = false;
  hm.manual.manpages.enable = false;
}
