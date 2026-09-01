{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.nvtopPackages.nvidia
  ];

  services.xserver.videoDrivers = ["nvidia"];

  # For when the beta drivers are broken with the later kernel version
  # https://www.nvidia.com/en-us/drivers/unix/
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "595.99.02"; # Copy the version number here
    sha256_64bit = "sha256-6HR3lYv3YwcFSTJL1a1slI66btIQ5EAFs+/4SUD24ew="; # "Cannot build "/nix/store/*-nvidia-x11-*"
    sha256_aarch64 = "";
    openSha256 = "sha256-T36x/jx8yQ8l3LFp1rZIrTfcSwbGy8YSAvXOUSptpb4="; # "Cannot build "/nix/store/*-nvidia-open-*"
    settingsSha256 = ""; # "Cannot build "/nix/store/*-nvidia-settings-*"
    persistencedSha256 = "";
  };

  hardware.nvidia = {
    # package = config.boot.kernelPackages.nvidiaPackages.beta;

    # Enables proprietary drivers
    modesetting.enable = true;
    open = true;
    # powerManagement.enable = true; Try when on the go

    # Half broken stuff
    nvidiaSettings = false;
    videoAcceleration = false;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  hardware.graphics.extraPackages = [pkgs.intel-media-driver];
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};
}
