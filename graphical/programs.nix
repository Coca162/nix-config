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
      qpwgraph
      filezilla
      easyeffects
      alsa-utils
      ((import (sources.nixpkgs-unstable {inherit pkgs;}) {}).deltachat-desktop.overrideAttrs {
        patches = [
          (sources."delta-remove-override-tilde.patch" {inherit pkgs;})
          (sources."delta-text-override-name.patch" {inherit pkgs;})
          (sources."delta-persistent-pk-overriding.patch" {inherit pkgs;})
        ];
      })
      ss14-launcher
      rescrobbled # TODO: wrap with config and https://github.com/InputUsername/rescrobbled/pull/223 when merge conflicts are fixed
      gamescope
      brightnessctl
      gram
    ]
    ++ [
      wrappers.alacritty
      wrappers.mpv
    ];

  programs.steam.enable = true;
  programs.kdeconnect.enable = true;
}
