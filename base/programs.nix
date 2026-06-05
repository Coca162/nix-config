{
  pkgs,
  lib,
  sources,
  wrappers,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      wl-clipboard-rs
      nvd
      nix-output-monitor
      lsof
      fatrace
      waypipe
      sshfs
      btrfs-progs
      nix-tree
      alejandra
      tokei
      kondo
      killall
      ripgrep
      ffmpeg-full
      ab-av1
      wget
      urlencode
      yt-dlp
      scdl
      dust
      nix-du
      nix-inspect
      graphviz
      libqalculate
      dig
      jq
      bat
      file
      openssl
      grex
      opustags
      opus-tools
      trashy
      zola
      minify
      nix-diff
      nixpkgs-reviewFull
      jmtpfs
      hyperfine
      lazygit
      fzf
    ]
    ++ [
      (pkgs.callPackage "${sources.unpins}/npins.nix" {})
      wrappers.zoxide
      wrappers.tealdeer
      wrappers.jujutsu
      wrappers.git
      wrappers.eza
      wrappers.direnv
      wrappers.fastfetch
      wrappers.hyfetch
      wrappers.btop
    ];

  programs.fish = {
    enable = true;
    package = wrappers.fish;
  };
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  environment.sessionVariables = {
    MANPAGER = "${lib.getExe pkgs.bat} --wrap=auto --language=man --plain --strip-ansi=auto";

    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=\${XDG_CONFIG_HOME}/java";
    DOTNET_CLI_HOME = "$XDG_DATA_HOME/dotnet";
    CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose";
    NUGET_PACKAGES = "$XDG_CACHE_HOME/NuGetPackages";
    ANDROID_USER_HOME = "$XDG_DATA_HOME/android";
    PARALLEL_HOME = "$XDG_CACHE_HOME/parallel";
    GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc";
  };

  hm.services.ssh-agent.enable = true;

  hm.programs.gpg = {
    enable = true;
    mutableKeys = true;
  };
}
