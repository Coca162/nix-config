{
  pkgs,
  lib,
  ...
}: let
  plasma = {
    programs = {
      gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
      ssh.enableAskPassword = true;
      ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    };
    environment.variables.SSH_ASKPASS_REQUIRE = "prefer";
    services = {
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };
  };
  niri = let
    update-wallpaper = pkgs.writers.writeNu "update-wallpaper" {
      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        "${lib.makeBinPath [pkgs.swww]}"
      ];
    } (builtins.readFile ./wallpaper.nu);
  in {
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
        pkgs.nushell
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
in {
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.xwayland.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam.enable = true;
  programs.kdeconnect.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.settings.no-allow-external-cache = "";

  fonts.packages = with pkgs; [
    google-fonts # EVER FONT IN EXISTENCE!!!
    cascadia-code
    monocraft
    miracode
  ];

  environment.systemPackages = with pkgs; [
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
    kdePackages.kdenlive
    kdePackages.kclock
    kdePackages.kruler
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
    deltachat-desktop
    signal-desktop
  ];

  home-manager.users.coca = {
    imports = [./home.nix];

    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
        "nu"
        "sql"
        "rainbow-csv"
        "env"
        "xml"
        "fish"
        "typst"
        "uiua"
        "just"
        "ssh-config"
        "git-firefly"
        "clojure"
        "scss"
      ];
      extraPackages = with pkgs; [
        nil
        nixd
        alejandra
      ];
      userSettings = {
        inlay_hints = {
          enabled = true;
          toggle_on_modifiers_press.shift = true;
        };
        lsp.rust-analyzer.initialization_options.inlayHints = {
          closureReturnTypeHints = {
            enable = "with_block";
          };
          lifetimeElisionHints = {
            enable = "skip_trivial";
            useParameterNames = true;
          };
          maxLength = 15;
        };
        lsp.nil.settings.formatting.command = [
          "${lib.getExe pkgs.alejandra}"
          "--"
        ];
        load_direnv = "direct";
        languages.Nix.format_on_save = "off";
        features.copilot = false;
        features.inline_completion_provider = "none";
        assistant.enabled = false;
        assistant.version = "1";
        assistant.button = false;
        assistant_v2.enabled = false;
        notification_panel.button = false;
        file_scan_exclusions = [
          # "**/.git"
          "**/.svn"
          "**/.hg"
          "**/.jj"
          "**/CVS"
          "**/.DS_Store"
          "**/Thumbs.db"
          "**/.classpath"
          "**/.settings"
        ];
        buffer_font_family = "Cascadia Code";
        buffer_font_weight = 350;
        buffer_font_features.zero = true; # Features do not work on Linux
        terminal.font_family = "Monocraft";
      };
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      mutableExtensionsDir = false;
    };

    programs.vscode.profiles.default = {
      extensions = with pkgs.vscode-extensions;
        [
          mkhl.direnv
          tamasfe.even-better-toml
          ecmel.vscode-html-css
          jnoortheen.nix-ide
          rust-lang.rust-analyzer
          vadimcn.vscode-lldb
          gruntfuggly.todo-tree
          thenuprojectcontributors.vscode-nushell-lang
          haskell.haskell
          justusadam.language-haskell
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "ayu-one-dark";
            publisher = "faceair";
            version = "1.1.1";
            sha256 = "sha256-HOqfEHskNYg8452EXZdt62ch1Yn9xM6tFXEBiw5aioA=";
          }
          {
            name = "crates-io";
            publisher = "BarbossHack";
            version = "0.7.5";
            sha256 = "sha256-eXLOr/XYhQgTl/gEjZQh97haFUgiqLNJn2P1uiMxPKg=";
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
        "nix.serverPath" = "${lib.getExe pkgs.nil}";
        "nix.serverSettings".nil.formatting.command = [
          "${lib.getExe pkgs.alejandra}"
          "--"
        ];
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
        "files.exclude"."**/.git" = false;
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
        terminal.shell.program = lib.getExe pkgs.fish;
        window.opacity = 0.85;
        window.decorations = "None";
        # Insane that the default opens links just by clicking on them??
        hints.enabled = [
          {
            command = "xdg-open";
            hyperlinks = true;
            post_processing = true;
            persist = false;
            mouse.enabled = true;
            mouse.mods = "Control";
            binding.key = "O";
            binding.mods = "Shift";
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
          }
        ];
      };
    };
  };

  specialisation = {
    plasma.configuration = plasma;
    # niri.configuration = niri;
  };

  imports = [
    (
      {config, ...}: {
        config = lib.mkIf (config.specialisation != {}) niri;
      }
    )
  ];
}
