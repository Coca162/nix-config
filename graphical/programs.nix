{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
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
    # libreoffice-qt6
    bitwarden-desktop
    obsidian
    reaper
    audacity
    qpwgraph
    filezilla
    easyeffects
    alsa-utils
    deltachat-desktop
    signal-desktop
    space-station-14-launcher
    rescrobbled
  ];

  programs.steam.enable = true;
  programs.kdeconnect.enable = true;
}
