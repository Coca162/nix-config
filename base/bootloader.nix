{
  pkgs,
  lib,
  ...
}: let
  # kernel = pkgs.callPackage ./_zen.nix {};
  kernel = pkgs.linuxKernel.manualConfig rec {
    pname = "linux-zen";
    version = "7.2.2";
    modDirVersion = lib.versions.pad 3 "${version}-zen1";
    configfile = ./kernel.config;
    isZen = true;
    features.efiBootStub = true;
    features.ia32Emulation = true;
    src = pkgs.fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "v7.2.2-zen1";
      hash = "sha256-KDPxfU+md/ii13KfwSz6IocPFma8Xe0T3xXlsIEj0GM=";
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
