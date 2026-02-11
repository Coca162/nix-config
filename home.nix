{
  config,
  pkgs,
  osConfig ? null,
  ...
}: {
  # The home.stateVersion option does not have a default and must be set, DO NOT CHANGE WITHOUT CARE
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    firefox
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
    dig
    jq
    bat
    file
    openssl
    grex
    opustags
    opusTools
    trashy
    zola
    minify
  ];

  home.sessionVariables = {
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.xdg.configHome}/java";
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
    XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose";
    NUGET_PACKAGES = "${config.xdg.cacheHome}/NuGetPackages";
  };

  programs.micro.enable = true;
  programs.micro.package = pkgs.micro-with-wl-clipboard;
  xdg.configFile."micro/bindings.json".text = builtins.toJSON {
    "Alt-s" = "Save";
    "Alt-q" = "Quit";
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      if test "true" = "$ENABLE_ZELLIJ"
         and test "niri" != "$XDG_CURRENT_DESKTOP"
         eval (zellij setup --generate-auto-start fish | string collect)
      end
    '';
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

  programs.zellij.enable = true;
  programs.zellij.enableFishIntegration = false;
  xdg.configFile."zellij/config.kdl".text = ''
    advanced_mouse_actions false

    keybinds {
        unbind "Ctrl q"
        shared_except "locked" {
            bind "Ctrl Alt q" { Quit; }
        }
    }
  '';
  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
        default_tab_template {
            children
            pane size=1 borderless=true {
                plugin location="compact-bar"
            }
        }

        tab focus=true name="Main" { pane; }

        swap_tiled_layout name="horizontal extra" {
            tab {
                pane {
                    pane stacked=true { children; }
                    pane; pane; pane;
                }
                pane
            }
        }

        swap_tiled_layout name="horizontal" {
            tab {
                pane stacked=true { children; }
                pane; pane;
            }
        }

        swap_tiled_layout name="vertical" {
            tab max_panes=4 {
                pane split_direction="vertical" {
                  pane
                  pane { pane; pane; }
                }
            }
            tab {
                pane split_direction="vertical" {
                  pane
                  pane stacked=true { children; }
                }
            }
        }
    }
  '';

  programs.lazygit.enable = true;

  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      cudaSupport = osConfig.hardware.nvidia.modesetting.enable or false;
    };
    settings.theme_background = false;
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.hyfetch = {
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

  programs.fastfetch.enable = true;
  programs.fastfetch.settings = {
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

  programs.mpv = {
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
      screenshot-directory = "${config.home.homeDirectory}/Pictures/mpv";
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  xdg.configFile."direnv/direnvrc".source = ./tmpfs_direnvrc.sh;

  services.ssh-agent.enable = true;

  programs.jujutsu = {
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

  programs.git = {
    enable = true;
    settings.user = {
      name = "Coca";
      email = "me@coca.codes";
    };
    signing.key = "0x03282DF88179AB19";
    signing.signByDefault = true;
  };

  programs.delta.enable = true;

  programs.difftastic = {
    enable = true;
    git.enable = true;
    git.diffToolMode = true;
  };

  programs.gpg = {
    enable = true;
    mutableKeys = true;
  };

  programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];
  };

  programs.fzf = {
    enable = true;
  };
}
