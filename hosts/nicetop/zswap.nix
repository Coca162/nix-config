{
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=50"
    "zswap.shrinker_enabled=1"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
  };

  boot.kernel.sysfs.module.zswap.parameters = {
    enabled = true;
    compressor = "zstd";
    max_pool_percent = 50;
    shrinker_enabled = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];
}
