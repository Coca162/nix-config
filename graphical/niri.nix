{
  lib,
  pkgs,
  wrappers,
  ...
}: {
  programs.niri = {
    enable = true;
    package = wrappers.niri;
    useNautilus = false;
  };
  xdg.portal = {
    config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce "kde";
    extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.kdePackages.xdg-desktop-portal-kde];
  };

  environment.systemPackages = with pkgs;
    [
      eww
      awww
      fuzzel
      xwayland-satellite
      swaylock
      mako
      ddcutil
      wl-screenrec
      slurp
      hicolor-icon-theme # fallback icons, again
      vellum
      wrappers.swayidle
      wrappers.satty
    ]
    ++ (with pkgs.kdePackages; [
      gwenview
      okular
      dolphin
      ark
      breeze-gtk
      ocean-sound-theme
      plasma-integration
      kservice
      (kdePackages.callPackage ./_elisa.nix {
        dragon-media-backend = pkgs.callPackage ./_dragon-media-backend.nix {};
      })
    ]);

  hardware.i2c.enable = true;
  systemd.user.services.niri = {
    wants = [
      "mako.service"
      "awww.service"
      "swayidle.service"
      "niri-flake-polkit.service"
      "vellum.service"
    ];
  };

  environment.etc."/xdg/menus/applications.menu".source = ./applications.xml;

  systemd.user.services.swayidle = {
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    requisite = ["graphical-session.target"];

    serviceConfig.ExecStart = lib.getExe wrappers.swayidle;
    path = [
      pkgs.swaylock
      wrappers.niri
      pkgs.awww
    ];
  };

  systemd.user.services.awww = {
    partOf = ["graphical-session.target"];
    after = [
      "graphical-session.target"
      "niri.service"
    ];
    requisite = ["graphical-session.target"];
    wants = ["update-wallpaper.timer" "update-wallpaper.service"];

    serviceConfig.ExecStart = lib.getExe' pkgs.awww "awww-daemon";
  };

  systemd.user.timers."update-wallpaper" = {
    bindsTo = ["awww.service"];
    after = ["awww.service"];
    timerConfig = {
      OnUnitActiveSec = "30min";
      Unit = "update-wallpaper.service";
    };
  };

  systemd.user.services."update-wallpaper" = {
    requires = ["awww.service"];
    after = ["awww.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writers.writeFish "update-wallpaper" {
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          "${lib.makeBinPath [pkgs.awww]}"
        ];
      } (builtins.readFile ./wallpaper.fish);
    };
  };

  xdg = {
    autostart.enable = true;
    menus.enable = true;
    mime.enable = true;
    icons.enable = true;
    icons.fallbackCursorThemes = ["breeze_cursors"];
  };

  systemd.user.services.niri-flake-polkit = {
    description = "PolicyKit Authentication Agent setup for niri";

    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    requisite = ["graphical-session.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  systemd.user.services.vellum = {
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    requisite = ["graphical-session.target"];

    serviceConfig = {
      ExecStart = lib.getExe pkgs.vellum;
      Restart = "on-failure";
    };
  };
}
