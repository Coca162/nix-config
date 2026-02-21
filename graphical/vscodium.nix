{
  pkgs,
  lib,
  ...
}: {
  hm.programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
  };

  hm.programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-extensions;
      [
        mkhl.direnv
        tamasfe.even-better-toml
        ecmel.vscode-html-css
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
        gruntfuggly.todo-tree
        haskell.haskell
        justusadam.language-haskell
        bmalehorn.vscode-fish
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
          version = "0.7.6";
          sha256 = "sha256-cWSw/qvlp/ylPjXjXBbJfpDDKxzhVxrcag6A0JvO9T0=";
        }
      ];

    userSettings = {
      "diffEditor.ignoreTrimWhitespace" = false;
      "editor.fontFamily" = "Cascadia Code";
      "editor.fontLigatures" = "'zero'";
      "editor.fontSize" = 15;
      "editor.inlayHints.enabled" = "onUnlessPressed";
      "git.autofetch" = false;
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
}
