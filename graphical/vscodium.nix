{
  baseVars,
  pkgs,
  lib,
  ...
}: let
  nil = pkgs.nil.overrideAttrs {
    patches = [
      (builtins.toFile
        "nix-doc-update.patch"
        ''
          diff --git a/crates/builtin/src/lib.rs b/crates/builtin/src/lib.rs
          index 719fe2b..f56ed19 100644
          --- a/crates/builtin/src/lib.rs
          +++ b/crates/builtin/src/lib.rs
          @@ -47,7 +47,9 @@ mod tests {
                               "\
           Return the names of the attributes in the set *set* in an
           alphabetically sorted list. For instance, `builtins.attrNames { y
          -= 1; x = \"foo\"; }` evaluates to `[ \"x\" \"y\" ]`.\
          += 1; x = \"foo\"; }` evaluates to `[ \"x\" \"y\" ]`.
          +
          +Has `O(l n log n)` time complexity, where `n` is number of attributes in the *set* and `l` is the maximum attribute name length.\
                           "
                           ),
                           impure_only: false,
          diff --git a/crates/ide/src/ide/hover.rs b/crates/ide/src/ide/hover.rs
          index 535bfde..09a82b0 100644
          --- a/crates/ide/src/ide/hover.rs
          +++ b/crates/ide/src/ide/hover.rs
          @@ -387,6 +387,8 @@ mod tests {
                           Return the first element of a list; abort evaluation if the argument
                           isn’t a list or is an empty list. You can test whether a list is
                           empty by comparing it with `[]`.
          +
          +                Has constant time complexity.
                       "#]],
                   );
               }
          @@ -404,6 +406,8 @@ mod tests {
                           Return the first element of a list; abort evaluation if the argument
                           isn’t a list or is an empty list. You can test whether a list is
                           empty by comparing it with `[]`.
          +
          +                Has constant time complexity.
                       "#]],
                   );
               }
        '')
    ];
  };

  settings = {
    "diffEditor.ignoreTrimWhitespace" = false;
    "editor.fontFamily" = "Cascadia Code";
    "editor.fontLigatures" = "'zero'";
    "editor.fontSize" = 15;
    "editor.inlayHints.enabled" = "onUnlessPressed";
    "git.autofetch" = false;
    "nix.enableLanguageServer" = true;
    # TODO: Don't reference these directly?
    "nix.serverPath" = "${lib.getExe nil}";
    "nix.serverSettings".nil.formatting.command = [
      "${lib.getExe pkgs.alejandra}"
      "--"
    ];
    "rust-analyzer.check.command" = "clippy";
    "rust-analyzer.diagnostics.enable" = false;
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
        name = "kdl-v1";
        publisher = "kdl-org";
        version = "1.4.1";
        sha256 = "sha256-9hC+0GEj6cxCgPk2R9OMPUrkqXaztV7xDLrQYPqAedg=";
      }
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

  vscodium-with-extensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = extensions;
  };

  jsonFormat = pkgs.formats.json {};

  inherit (baseVars) username;
  userDir = "/.config/VSCodium/User";
  keybindingsPath = "${userDir}/keybindings.json";
  settingsPath = "${userDir}/settings.json";
in {
  users.users.${username}.packages = [vscodium-with-extensions];

  systemd.user.tmpfiles.users.${username}.rules = [
    "L+ %h${settingsPath} - - - - ${jsonFormat.generate "vscode-user-settings" settings}"
    "L+ %h${keybindingsPath} - - - - ${jsonFormat.generate "vscode-keybindings" keybindings}"
  ];
}
