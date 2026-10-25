{
  systemd.mounts = [
    {
      description = "Mount for btrfs 2TB external drive";
      what = "/dev/disk/by-uuid/a0e08bb3-18b0-4ee8-a402-0e00f9220a68";
      where = "/data/btrfs-external";
      type = "btrfs";
      options = "defaults,rw";
    }
  ];

  systemd.automounts = [
    {
      description = "Automount for btrfs 2TB external drive";
      where = "/data/btrfs-external";
      wantedBy = ["multi-user.target"];
      automountConfig.TimeoutIdleSec = 5;
    }
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id != "org.freedesktop.systemd1.manage-units" || subject.user != "coca") {
            return;
        }

        const unit = action.lookup("unit");
        if (unit != "data-btrfs\\x2dexternal.automount" && unit != "data-btrfs\\x2dexternal.mount") {
            return;
        }

        const verb = action.lookup("verb");
        if (verb == "start" || verb == "stop" || verb == "restart") {
            return polkit.Result.YES;
        }
    });
  '';
}
