{
  config,
  pkgs,
  lib,
  osConfig ? null,
  ...
}: {
  /*
  The home.stateVersion option does not have a default and must be set, DO NOT CHANGE WITHOUT CARE
  */
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    firefox
    reaper
    audacity
    alejandra
    nil
    tokei
    eza
    kondo
    killall
    ripgrep
    ffmpeg-full
    wget
    yt-dlp
    scdl
    inetutils
    du-dust
    nix-du
    nix-inspect
    graphviz
    dig
    jq
    bat
    file
    openssl
    filezilla
    grex
    nushell
    nushellPlugins.query
    opustags
    opusTools
    (import ./spawn-terminal.nix pkgs)
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions;
      [
        fill-labs.dependi
        mkhl.direnv
        tamasfe.even-better-toml
        ecmel.vscode-html-css
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
        gruntfuggly.todo-tree
        thenuprojectcontributors.vscode-nushell-lang
        mhutchie.git-graph
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "ayu-one-dark";
          publisher = "faceair";
          version = "1.1.1";
          sha256 = "sha256-HOqfEHskNYg8452EXZdt62ch1Yn9xM6tFXEBiw5aioA=";
        }
      ];
    userSettings = {
      "diffEditor.ignoreTrimWhitespace" = false;
      "editor.fontFamily" = "Cascadia Code";
      "editor.fontLigatures" = "'zero'";
      "editor.fontSize" = 15;
      "editor.inlayHints.enabled" = "onUnlessPressed";
      "git.autofetch" = true;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings".nil.formatting.command = ["${pkgs.alejandra}/bin/alejandra" "--"];
      "[nix]"."editor.formatOnSave" = true;
      "rust-analyzer.check.command" = "clippy";
      "terminal.integrated.fontFamily" = "Monocraft";
      "todo-tree.general.tags" = [
        "BUG"
        "HACK"
        "FIXME"
        "TODO"
        "XXX"
        "[ ]"
        "[x]"
        "todo!"
      ];
      "window.customTitleBarVisibility" = "auto";
      "workbench.colorTheme" = "Ayu One Dark";
      "editor.semanticTokenColorCustomizations"."[Ayu One Dark]" = {
        enabled = true;
        rules = let
          gray = {
            italic = false;
            foreground = "#ABB2BF";
          };
        in {
          "property:nix" = gray;
          "parameter:nix" = gray;
          "variable:nix" = gray;
          "function:nix".italic = false;
        };
      };
    };
    keybindings = [
      {
        key = "ctrl+r";
        command = "editor.action.rename";
        when = "editorHasRenameProvider && editorTextFocus && !editorReadonly";
      }
      {
        key = "f2";
        command = "-editor.action.rename";
        when = "editorHasRenameProvider && editorTextFocus && !editorReadonly";
      }
    ];
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

      if contains "true" $ENABLE_ZELLIJ
        eval (zellij setup --generate-auto-start fish | string collect)
      end
    '';
    functions.trash = "function trash; mv $argv /tmp/$argv; end";
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
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 11;
        normal.family = "monocraft";
      };
      env = {
        ZELLIJ_AUTO_ATTACH = "true";
        ENABLE_ZELLIJ = "true";
      };
      terminal.shell.program = "${pkgs.fish}/bin/fish";
      window.opacity = 0.85;
    };
  };

  programs.zellij = {
    enable = true;
    settings.default_layout = "compact";
  };

  programs.lazygit.enable = true;

  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  programs.btop = {
    enable = true;
    package = pkgs.btop.override {cudaSupport = osConfig.hardware.nvidia.modesetting.enable or false;};
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
    config.screenshot-directory = "${config.home.homeDirectory}/Pictures/mpv";
    scripts = with pkgs.mpvScripts; [thumbfast (import ./thumbfast-osc.nix pkgs) visualizer];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  xdg.configFile."direnv/direnvrc".source = ./tmpfs_direnvrc.sh;

  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;
    userName = "Coca";
    userEmail = "coca16622@gmail.com";
    signing.key = "0x03282DF88179AB19";
    signing.signByDefault = true;
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

  home.file.".cargo/config.toml".text = ''
    [target.x86_64-unknown-linux-gnu]
    linker = "${pkgs.llvmPackages.clangUseLLVM}/bin/clang"
    rustflags = ["-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold", "-C", "target-cpu=native"]
  '';
}
