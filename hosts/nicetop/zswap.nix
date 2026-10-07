{
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=50"
    "zswap.shrinker_enabled=1"

    # I'm doing this in a attempt to make hibernation consistently work (sometimes it fails)
    # from run0 filefrag -v /var/lib/swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'
    # see https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Acquire_swap_file_offset
    "resume_offset=148936704"
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
