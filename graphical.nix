{
  pkgs,
  lib,
  ...
}: {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
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

  programs.ssh.enableAskPassword = true;
  programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
  environment.variables.SSH_ASKPASS_REQUIRE = "prefer";

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam.enable = true;

  programs.kdeconnect.enable = true;

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
  services.dbus.packages = [pkgs.pinentry-qt];

  fonts.packages = with pkgs; [
    google-fonts # EVER FONT IN EXISTENCE!!!
    cascadia-code
    monocraft
    miracode
  ];

  environment.systemPackages = with pkgs; [
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
    aseprite
    obs-studio
    wayfarer # Spectacle recording is a bit unreliable
    # blender BROKEN
    libreoffice-qt6
    onlyoffice-bin
    bitwarden-desktop
    obsidian
    reaper
    audacity
    qpwgraph
    filezilla
  ];

  home-manager.users.coca = {
    imports = [./home.nix];

    programs.zed-editor = {
      enable = true;
      extensions = ["nix" "toml" "nu" "rainbow-csv" "env" "xml" "fish" "typst" "uiua" "just" "ssh-config" "git-firefly"];
      extraPackages = with pkgs; [nil nixd alejandra];
      userSettings = {
        lsp.nil.settings.formatting.command = ["${lib.getExe pkgs.alejandra}" "--"];
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
          # vadimcn.vscode-lldb BROKEN
          gruntfuggly.todo-tree
          thenuprojectcontributors.vscode-nushell-lang
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
            version = "0.7.3";
            sha256 = "sha256-eTdCVejiVDQBJa9Q03QhbPmSumhkzxZcCxvuoWvJ8Es=";
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
        "nix.serverSettings".nil.formatting.command = ["${lib.getExe pkgs.alejandra}" "--"];
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
        terminal.shell.program = "${pkgs.fish}/bin/fish";
        window.opacity = 0.85;
      };
    };
  };
}
