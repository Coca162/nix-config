{
  pkgs,
  lib,
  sources,
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
    kate
    osu-lazer-bin
    bitwig-studio
    pinta
    gimp
    krita
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
    filezilla
    (let
      pkgs = import (builtins.fetchTarball {
        # Descriptive name to make the store path easier to identify
        name = "nixos-24.11";
        # Commit hash for nixos-unstable as of 2018-09-12
        url = "https://github.com/nixos/nixpkgs/archive/d9d87c51960050e89c79e4025082ed965e770d68.tar.gz";
        # Hash obtained using `nix-prefetch-url --unpack <url>`
        sha256 = "1na5ljrqhbq7x7zln7gi8588nwwnsgb8qlid2z9zckjpsyjipy3c";
      }) {};
    in
      pkgs.termusic)
  ];

  home-manager.users.coca = {
    imports = [./home.nix];

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
          ((import sources.fix-rust-analyzer {}).vscode-extensions.rust-lang.rust-analyzer)
          # vadimcn.vscode-lldb BROKEN
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
