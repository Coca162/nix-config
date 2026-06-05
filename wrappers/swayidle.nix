_: {
  options.configContents.default = ''
    timeout 200 'swaylock -f -c 000000'
    timeout 180 'niri msg action power-off-monitors'
  '';
}
