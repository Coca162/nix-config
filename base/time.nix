{
  services.ntpd-rs = {
    enable = true;
    useNetworkingTimeServers = false;
  };

  services.ntpd-rs.settings.observability = {
    log-level = "info";
  };

  services.ntpd-rs.settings.source = [
    {
      mode = "nts-pool";
      enable-srv-resolution = true;
      address = "srv.sectime.org";
    }
  ];
}
