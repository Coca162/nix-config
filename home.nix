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
    vscodium-fhs
    obsidian
    reaper
    audacity
    tree
    alejandra
    nil
    tokei
    eza
    cascadia-code
    monocraft
    miracode
    killall
    ripgrep
    wget
    yt-dlp
    inetutils
    du-dust
    dig
    jq
    tldr
    fastfetch
    filezilla
    grex
    (import ./spawn-terminal.nix pkgs)
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      if contains "true" $ENABLE_ZELLIJ
        eval (zellij setup --generate-auto-start fish | string collect)
      end
    '';
    functions.trash = "function trash; mv $argv /tmp/$argv; end";
    shellAliases = {
      ls = "eza -a";
      lsa = "eza -ambhlU";
      dir = "eza --only-dirs";
      dirs = "eza --only-dirs";
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
      shell.program = "${pkgs.fish}/bin/fish";
      window.opacity = 0.85;
    };
  };

  programs.zellij = {
    enable = true;
    settings.default_layout = "compact";
  };

  programs.btop = {
    enable = true;
    package =
      if osConfig.hardware.nvidia.modesetting.enable or false
      then pkgs.btop.override {cudaSupport = true;}
      else pkgs.btop;
    settings.theme_background = false;
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

  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
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
    };
    config.screenshot-directory = "${config.home.homeDirectory}/Pictures/mpv";
    package =
      pkgs.wrapMpv
      (pkgs.mpv-unwrapped.override {sixelSupport = true;})
      {scripts = with pkgs.mpvScripts; [sponsorblock thumbfast (import ./thumbfast-osc.nix pkgs) visualizer];};
  };

  programs.direnv.enable = true;

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

  services.gpg-agent.enable = true;

  programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];
  };

  programs.fzf = {
    enable = true;
  };
}
