{
  pkgs,
  lib,
  ...
}: let
  version = "7.2.7";
  suffix = "zen1";
  kernel = pkgs.linuxKernel.manualConfig {
    inherit version;
    pname = "linux-zen";
    modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
    configfile = ./kernel.config;
    isZen = true;
    features.efiBootStub = true;
    features.ia32Emulation = true;
    src = pkgs.fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "v${version}-${suffix}";
      hash = "sha256-9yaSXKYTAr7G+rNK49M2m75xQ7BgMCdtTJZsZpO3Br4=";
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
