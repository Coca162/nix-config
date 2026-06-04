{
  config,
  pkgs,
  lib,
  sources,
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
      eza
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
    ]
    ++ [
      (pkgs.callPackage "${sources.unpins}/npins.nix" {})
    ];

  programs.fish.enable = true;
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;
  environment.variables.MANPAGER = "${lib.getExe pkgs.bat} --wrap=auto --language=man --plain --strip-ansi=auto";

  environment.sessionVariables = {
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

  hm.programs.micro.enable = true;
  hm.programs.micro.package = pkgs.micro-with-wl-clipboard;
  hm.xdg.configFile."micro/bindings.json".text = builtins.toJSON {
    "Alt-s" = "Save";
    "Alt-q" = "Quit";
  };

  hm.programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      if test "true" = "$ENABLE_ZELLIJ"
         and test "niri" != "$XDG_CURRENT_DESKTOP"
         eval (zellij setup --generate-auto-start fish | string collect)
      end
    '';
    functions = {
      callpackage = ''nix-build --expr "(import <nixpkgs> {}).callPackage $(realpath $argv[1]) {$argv[2]}" --no-link'';
    };
    shellAliases = rec {
      ls = "eza -a";
      lsa = "eza -ambhlU --icons";
      tree = "eza --tree -mbhlu --icons";
      dirs = "eza --only-dirs";
      dir = dirs;
      nano = "nano -c";
      grep = "rg";
      loc = "tokei";
      neofetch = "hyfetch";
      qdl = ''yt-dlp --cookies-from-browser firefox -o "$XDG_RUNTIME_DIR/quick-yt-dlp/%(title)s.%(ext)s" --exec "urlencode -e fragment \"file://%(filepath)s\" | wl-copy -t text/uri-list"'';
    };
  };

  hm.programs.lazygit.enable = true;

  hm.programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  hm.programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      cudaSupport = config.hardware.nvidia.modesetting.enable or false;
    };
    settings.theme_background = false;
  };

  hm.programs.hyfetch = {
    enable = true;
    settings = {
      args = null;
      backend = "neofetch"; # Lists steam and user nix packages, fastfetch does not
      color_align = {
        custom_colors."1" = 3;
        custom_colors."2" = 2;
        fore_back = [];
        mode = "custom";
      };
      distro = null;
      light_dark = "dark";
      lightness = 0.65;
      mode = "rgb";
      preset = "agender";
      pride_month_disable = false;
      pride_month_shown = [];
    };
  };

  hm.programs.fastfetch.enable = true;
  hm.programs.fastfetch.settings = {
    modules = [
      "title"
      "separator"
      "os"
      "host"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "display"
      "de"
      "wm"
      "wmtheme"
      "theme"
      "icons"
      "font"
      "cursor"
      "terminal"
      "terminalfont"
      "cpu"
      "gpu"
      "memory"
      "swap"
      "disk"
      "battery"
      "poweradapter"
      "locale"
      "break"
      "colors"
    ];
  };

  hm.programs.mpv = {
    enable = true;
    bindings = {
      RIGHT = "seek  5";
      LEFT = "seek  -5";
      UP = "seek  60";
      DOWN = "seek  -60";
      "Shift+RIGHT" = "no-osd seek  1";
      "Shift+LEFT" = "no-osd seek  -1";
      "[" = "add speed -0.05";
      "]" = "add speed 0.05";
      "Ctrl+[" = "add speed -0.25";
      "Ctrl+]" = "add speed 0.25";
      "{" = "multiply speed 0.5";
      "}" = "multiply speed 2.0";
      "9" = "add volume -5";
      "0" = "add volume 5";
    };
    config = {
      screenshot-directory = "~/Pictures/mpv";
      screenshot-template = "Screenshot_%tY%tm%td_%tH%tM%tS"; # %m/%d/%Y, %H:%M:%S
      screenshot-format = "png";
      volume = 20;
      volume-max = 150;
    };
    scripts = with pkgs.mpvScripts; [
      visualizer
      thumbfast
      thumbfast-osc
      mpris
    ];
  };

  hm.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  hm.xdg.configFile."direnv/direnvrc".source = ./tmpfs_direnvrc.sh;

  hm.services.ssh-agent.enable = true;

  hm.programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Coca";
        email = "me@coca.codes";
      };
      signing = {
        behaviour = "drop";
        backend = "gpg";
        key = "0x03282DF88179AB19";
      };
      git.sign-on-push = true;
    };
  };

  hm.programs.git = {
    enable = true;
    settings.init.defaultBranch = "main";
    settings.user = {
      name = "Coca";
      email = "me@coca.codes";
    };
    signing.key = "0x03282DF88179AB19";
    signing.format = "openpgp";
    signing.signByDefault = true;
  };

  hm.programs.delta.enable = true;

  hm.programs.difftastic = {
    enable = true;
    git.enable = true;
    git.diffToolMode = true;
  };

  hm.programs.gpg = {
    enable = true;
    mutableKeys = true;
  };

  hm.programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];
  };

  hm.programs.fzf = {
    enable = true;
  };
}
