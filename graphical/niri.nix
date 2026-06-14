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
      wrappers.swayidle
    ]
    ++ (with pkgs.kdePackages; [
      elisa
      gwenview
      okular
      dolphin
      breeze
      ark
      breeze-icons
      breeze-gtk
      ocean-sound-theme
      qqc2-breeze-style
      qqc2-desktop-style
      plasma-integration
      kservice
      (qt6ct.overrideAttrs {
        patches = pkgs.fetchurl {
          url = "https://aur.archlinux.org/cgit/aur.git/plain/qt6ct-shenanigans.patch?h=qt6ct-kde";
          hash = "sha256-gXtwFPLT4e6Y3Y3NdEltOkSFj6cUOAZMqrqLxatR5Pk=";
        };
      })
    ]);

  hardware.i2c.enable = true;
  systemd.user.services.niri = {
    wants = [
      "mako.service"
      "awww.service"
      "swayidle.service"
    ];
    path = [
      "/run/wrappers"
      "/home/coca/.nix-profile"
      "/nix/profile"
      "/home/coca/.local/state/nix/profile"
      "/etc/profiles/per-user/coca"
      "/nix/var/nix/profiles/default"
      "/run/current-system/sw"
    ];
  };

  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
  };

  environment.etc."/xdg/menus/applications.menu".source = ./applications.xml;

  systemd.user.services.swayidle = {
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    bindsTo = ["graphical-session.target"];

    serviceConfig.ExecStart = lib.getExe wrappers.swayidle;
    path = [
      pkgs.swaylock
      pkgs.niri
      pkgs.awww
    ];
  };

  systemd.user.services.awww = {
    partOf = ["graphical-session.target"];
    after = [
      "graphical-session.target"
      "niri.service"
    ];
    bindsTo = ["graphical-session.target"];
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
    wantedBy = ["niri.service"];
    after = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
