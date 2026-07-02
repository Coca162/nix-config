{
  pkgs,
  wrappers,
  sources,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      firefox
      libnotify
      playerctl
      gparted
      qdirstat
      osu-lazer-bin
      bitwig-studio
      pinta
      gimp
      krita
      kdePackages.kate
      kdePackages.kclock
      kdePackages.kruler
      kdePackages.akregator
      inkscape
      prismlauncher
      qbittorrent
      qt6.qtimageformats
      # aseprite BROKEN
      obs-studio
      wayfarer # Spectacle recording is a bit unreliable
      # blender BROKEN
      libreoffice-qt6
      bitwarden-desktop
      obsidian
      reaper
      audacity
      qpwgraph
      filezilla
      easyeffects
      alsa-utils
      (deltachat-desktop.overrideAttrs {
        patches = [sources."delta-no-override-tilde.patch" sources."delta-override-name.patch"];
      })
      space-station-14-launcher
      rescrobbled # TODO: wrap with config and https://github.com/InputUsername/rescrobbled/pull/223 when merge conflicts are fixed
      gamescope
      brightnessctl
    ]
    ++ [
      wrappers.alacritty
      (
        mpv.override {
          mpv-unwrapped =
            wrappers.mpv
            // {
              inherit (pkgs.mpv-unwrapped) version meta;
            };
          scripts = with mpvScripts; [
            visualizer
            thumbfast
            thumbfast-osc
            mpris
          ];
        }
      )
    ];

  programs.steam.enable = true;
  programs.kdeconnect.enable = true;
}
