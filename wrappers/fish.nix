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
      f-copy = ''
        function f-copy
          echo (urlencode -e fragment file://(realpath $argv[1])) | wl-copy -t text/uri-list
        end
      '';
      pick_and_copy_color = ''
        function pick_and_copy_color
            niri msg pick-color | string match -gr '(#[[:xdigit:]]+)' | read -l hex
            wl-copy -n $hex
        end
      '';
      git-prs = ''
        function git-prs -a remote
          git config "remote.$remote.fetch" "+refs/pull/*:refs/remotes/$remote/pull/*"
        end
      '';
    };
    abbreviations.mutators = ["/fish" "/eza" "/hyfetch" "/git"];
    interactiveShellInit.mutators = ["/fish" "/direnv" "/zoxide"];
  };

  mutations = {
    "/fish".interactiveShellInit = ''
      set fish_greeting # Disable greeting

      if test "true" = "$ENABLE_ZELLIJ"
         and test "niri" != "$XDG_CURRENT_DESKTOP"
         eval (zellij setup --generate-auto-start fish | string collect)
      end
    '';
    "/fish".abbreviations = {
      wl = "whichlink";
      copyl = "f-copy";
      nano = "nano -c";
      grep = "rg";
      loc = "tokei";
      qdl = ''yt-dlp --cookies-from-browser firefox -o "$XDG_RUNTIME_DIR/quick-yt-dlp/%(title)s.%(ext)s" --exec "echo file://%(filepath)q | wl-copy -t text/uri-list"'';
    };
  };
}
