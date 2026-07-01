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
      jmtpfs
      hyperfine
      lazygit
      fzf
    ]
    ++ [
      (
        pkgs.nix-output-monitor.overrideAttrs (prev: {
          version = "0-unstable-2026-06-08";
          src = pkgs.fetchFromGitHub {
            owner = "maralorn";
            repo = "nix-output-monitor";
            rev = "388f56120f655a9cf4512e697b2c2afa06fe7434";
            hash = "sha256-3N+PVFpsnBtQ11Vk9OKm1q9dE0d5fxGsEDyfwoxpYaE=";
          };
          propagatedBuildInputs =
            (prev.propagatedBuildInputs or [])
            ++ [
              pkgs.haskellPackages.hinotify
            ];
        })
      )
      wrappers.zoxide
      wrappers.tealdeer
      wrappers.jujutsu
      wrappers.git
      wrappers.eza
      wrappers.fastfetch
      wrappers.hyfetch
      wrappers.btop
      wrappers.gnupg
    ]
    # Every package with a dep on nix
    # excluding nil (derivation used in vscodium settings)
    ++ [
      pkgs.nix-du
      pkgs.nixpkgs-reviewFull
      (pkgs.callPackage "${sources.unpins}/npins.nix" {})
      wrappers.direnv
    ];

  programs.fish = {
    enable = true;
    useBabelfish = true;
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

  programs.ssh.startAgent = true;
  # No idea what sets this
  # It doesn't even work!
  services.gnome.gcr-ssh-agent.enable = false;

  # Speed is key.
  documentation.nixos.enable = false;
}
