{pkgs, ...}: {
  fonts.packages = with pkgs; [
    google-fonts # EVER FONT IN EXISTENCE!!!
    monocraft
    miracode
  ];

  fonts.fontconfig.defaultFonts.monospace = [
    "DejaVu Sans Mono"
    "Cascadia Mono"
  ];
}
