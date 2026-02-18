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
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
  #   version = "580.119.02"; # Copy the version number here
  #   sha256_64bit = "sha256-gCD139PuiK7no4mQ0MPSr+VHUemhcLqerdfqZwE47Nc="; # "Cannot build "/nix/store/*-nvidia-x11-*"
  #   sha256_aarch64 = "";
  #   openSha256 = "sha256-l3IQDoopOt0n0+Ig+Ee3AOcFCGJXhbH1Q1nh1TEAHTE="; # "Cannot build "/nix/store/*-nvidia-open-*"
  #   settingsSha256 = "sha256-sI/ly6gNaUw0QZFWWkMbrkSstzf0hvcdSaogTUoTecI="; # "Cannot build "/nix/store/*-nvidia-settings-*"
  #   persistencedSha256 = "";
  # };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # Enables proprietary drivers
    modesetting.enable = true;
    open = true;
    # powerManagement.enable = true; Try when on the go

    # Half broken stuff
    nvidiaSettings = false;
    videoAcceleration = false;
  };

  hardware.graphics.extraPackages = [pkgs.intel-media-driver];
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};
}
