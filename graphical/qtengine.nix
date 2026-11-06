{pkgs, ...}: let
  settings = {
    theme = {
      colorScheme = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
      iconTheme = "breeze-dark";
      style = "breeze";
      # quickStyle = "org.kde.breeze"; Set if you actualy need it with qqc2-breeze-style in packages

      font.size = 9;
      fontFixed.size = 9;
    };

    misc = {
      singleClickActivate = false;
    };
  };

  jsonFormat = pkgs.formats.json {};
in {
  environment = {
    # Add your desired theme to your system packages
    systemPackages = with pkgs.kdePackages; [
      breeze
      breeze-icons
      pkgs.qtengine
    ];

    sessionVariables.QT_QPA_PLATFORMTHEME = "qtengine";

    etc."xdg/qtengine/config.json".source = jsonFormat.generate "qtengine-config.json" settings;
  };
}
