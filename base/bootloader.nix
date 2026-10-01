{
  pkgs,
  lib,
  ...
}: let
  version = "7.2.8";
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
      hash = "sha256-5pYE8uA4s48Q3KQXKHrHkcU4Wh/Gdu5a2vfs5U3Zimw=";
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
