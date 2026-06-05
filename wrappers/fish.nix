_: {
  options = {
    functions.default = {
      callpackage = ''nix-build --expr "(import <nixpkgs> {}).callPackage $(realpath $argv[1]) {$argv[2]}" --no-link'';
    };
    abbreviations.mutators = ["/fish" "/eza"];
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
    # TODO: move some of these to their own wrappers
    "/fish".abbreviations = _: {
      nano = "nano -c";
      grep = "rg";
      loc = "tokei";
      neofetch = "hyfetch";
      qdl = ''yt-dlp --cookies-from-browser firefox -o "$XDG_RUNTIME_DIR/quick-yt-dlp/%(title)s.%(ext)s" --exec "urlencode -e fragment \"file://%(filepath)s\" | wl-copy -t text/uri-list"'';
    };
  };
}
