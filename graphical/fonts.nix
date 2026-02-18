{pkgs, ...}: {
  fonts.packages = with pkgs; [
    google-fonts # EVER FONT IN EXISTENCE!!!
    cascadia-code
    monocraft
    miracode
  ];
}
