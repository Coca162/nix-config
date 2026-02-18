{
  baseVars,
  hostVars,
  ...
}: {
  networking.hostName = hostVars.hostname;

  networking.extraHosts = ''
    0.0.0.0 wplace.live
  '';

  networking.networkmanager.enable = true;

  users.users.${baseVars.username}.extraGroups = ["networkmanager" "pcap"];
  programs.tcpdump.enable = true;
}
