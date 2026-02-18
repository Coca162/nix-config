{
  config,
  lib,
  pkgs,
  ...
}: let
  update-wallpaper = pkgs.writers.writeFish "update-wallpaper" {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [pkgs.swww]}"
    ];
  } (builtins.readFile ./wallpaper.fish);
in {
  config = lib.mkIf (config.specialisation != {}) {
    programs.niri.enable = true;
    programs.niri.useNautilus = false;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    environment.systemPackages = with pkgs;
    with pkgs.kdePackages; [
      eww
      swww
      fuzzel
      xwayland-satellite
      elisa
      gwenview
      okular
      dolphin
      breeze
      ark
      breeze-icons
      breeze-gtk
      ocean-sound-theme
      plasma-workspace-wallpapers
      pkgs.hicolor-icon-theme # fallback icons
      qqc2-breeze-style
      qqc2-desktop-style
      plasma-integration
      kservice
      swayidle
      swaylock
      mako
      ddcutil
      wl-screenrec
      slurp
      (qt6ct.overrideAttrs {
        patches = pkgs.fetchurl {
          url = "https://aur.archlinux.org/cgit/aur.git/plain/qt6ct-shenanigans.patch?h=qt6ct-kde";
          sha256 = "1igxin99ia0a5c8j00d43gpvgkwygv2iphjxhw1bx52aqm3054sm";
        };
      })
    ];
    hardware.i2c.enable = true;
    systemd.user.services.niri = {
      wants = [
        "mako.service"
        "swww.service"
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

    environment.etc."/xdg/menus/applications.menu".text =
      builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

    systemd.user.services.swayidle = {
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      bindsTo = ["graphical-session.target"];

      serviceConfig.ExecStart = lib.getExe pkgs.swayidle;
      path = [
        pkgs.swaylock
        pkgs.niri
        pkgs.jq
        pkgs.uutils-findutils
        pkgs.swww
      ];
    };

    systemd.user.services.swww = {
      partOf = ["graphical-session.target"];
      after = [
        "graphical-session.target"
        "niri.service"
      ];
      bindsTo = ["graphical-session.target"];

      serviceConfig.ExecStart = lib.getExe' pkgs.swww "swww-daemon";
      serviceConfig.ExecStartPost = update-wallpaper;
    };

    systemd.user.timers."update-wallpaper" = {
      wantedBy = ["swww.service"];
      requires = ["swww.service"];
      timerConfig = {
        OnUnitActiveSec = "30min";
        Unit = "update-wallpaper.service";
      };
    };

    systemd.user.services."update-wallpaper" = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = update-wallpaper;
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
      description = "PolicyKit Authentication Agent provided by niri-flake";
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
  };
}
