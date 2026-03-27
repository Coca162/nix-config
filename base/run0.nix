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

  environment.etc."polkit-1/polkitd.conf".text = ''
    [Polkitd]
    ExpirationSeconds=120
  '';
}
