_: {
  options = {
    package.defaultFunc = {inputs}: let
      inherit (inputs.nixpkgs.pkgs) mpv mpvScripts;
    in
      mpv.override {
        scripts = with mpvScripts; [
          visualizer
          thumbfast
          thumbfast-osc
          mpris
        ];
      };

    settings.default = {
      screenshot-directory = "~/Pictures/mpv";
      screenshot-template = "Screenshot_%tY%tm%td_%tH%tM%tS"; # %m/%d/%Y, %H:%M:%S
      screenshot-format = "png";
      volume = 20;
      volume-max = 150;
    };

    keybinds.default = {
      RIGHT = "seek  5";
      LEFT = "seek  -5";
      UP = "seek  60";
      DOWN = "seek  -60";
      "Shift+RIGHT" = "no-osd seek  1";
      "Shift+LEFT" = "no-osd seek  -1";
      "[" = "add speed -0.05";
      "]" = "add speed 0.05";
      "Ctrl+[" = "add speed -0.25";
      "Ctrl+]" = "add speed 0.25";
      "{" = "multiply speed 0.5";
      "}" = "multiply speed 2.0";
      "9" = "add volume -5";
      "0" = "add volume 5";
    };
  };
}
