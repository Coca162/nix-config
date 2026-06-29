{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_zen;
  system.boot.loader.kernelFile = "vmlinuz";

  boot.supportedFilesystems = ["ntfs"];
  boot.kernel.sysctl."kernel.sysrq" = 1;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
