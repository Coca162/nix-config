{
  pkgs,
  lib,
  ...
}: let
  # kernel = pkgs.callPackage ./_zen.nix {};
  kernel = pkgs.linuxKernel.manualConfig rec {
    pname = "linux-zen";
    version = "7.2.4";
    modDirVersion = lib.versions.pad 3 "${version}-zen2";
    configfile = ./kernel.config;
    isZen = true;
    features.efiBootStub = true;
    features.ia32Emulation = true;
    src = pkgs.fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "v7.2.4-zen2";
      sha256 = "1n8597gzym8fm9d18k4wczmngjg9id7dqgi8y8ak53iy6q0pwlsv";
    };

    extraMakeFlags = [
      "KCFLAGS+=-march=tigerlake"
      "KCFLAGS+=-mtune=tigerlake"
      "KCPPFLAGS+=-march=tigerlake"
      "KCPPFLAGS+=-mtune=tigerlake"
    ];
  };
in {
  boot.kernelPackages = lib.recurseIntoAttrs (pkgs.linuxKernel.packagesFor kernel);

  # for custom kernel easiness
  boot.initrd.includeDefaultModules = false;

  boot.supportedFilesystems = ["ntfs"];
  boot.kernel.sysctl."kernel.sysrq" = 1;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
