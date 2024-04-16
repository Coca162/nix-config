pkgs:
pkgs.writeShellApplication {
  name = "spawn-terminal";

  runtimeInputs = with pkgs; [killall ripgrep unixtools.procps alacritty];

  text = ''
    if ps -e | rg alacritty; then
        killall alacritty
    fi

    alacritty
  '';
}
