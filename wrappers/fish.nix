_: {
  options = {
    functions.default = {
      callpackage = ''
        function callpackage -a path attrset
          nix-build --expr "(import <nixpkgs> {}).callPackage $(realpath $path) {$attrset}" --no-link
        end
      '';
      whichlink = ''
        function whichlink -a command
          readlink --canonicalize-existing (which $command)
        end
      '';
      copyl = ''
        function copyl
          echo (urlencode -e fragment file://(realpath $argv[1])) | wl-copy -t text/uri-list
        end
      '';
    };
    abbreviations.mutators = ["/fish" "/eza" "/hyfetch"];
    interactiveShellInit.mutators = ["/fish" "/direnv" "/zoxide"];
  };

  mutations = {
    "/fish".interactiveShellInit = _: ''
      set fish_greeting # Disable greeting

      if test "true" = "$ENABLE_ZELLIJ"
         and test "niri" != "$XDG_CURRENT_DESKTOP"
         eval (zellij setup --generate-auto-start fish | string collect)
      end
    '';
    "/fish".abbreviations = _: {
      wl = "whichlink";
      nano = "nano -c";
      grep = "rg";
      loc = "tokei";
      qdl = ''yt-dlp --cookies-from-browser firefox -o "$XDG_RUNTIME_DIR/quick-yt-dlp/%(title)s.%(ext)s" --exec "urlencode -e fragment \"file://%(filepath)s\" | wl-copy -t text/uri-list"'';
    };
  };
}
