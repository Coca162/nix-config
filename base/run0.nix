{
  security.sudo.enable = false;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (
            action.id == "org.freedesktop.systemd1.run" &&
            subject.isInGroup("wheel")
        ) {
            return polkit.Result.AUTH_KEEP;
        }
    });
  '';

  security.polkit.settings.Polkitd.ExpirationSeconds = 240;
}
