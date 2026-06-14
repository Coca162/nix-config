_: {
  options.settings.default = {
    modules = [
      "title"
      "separator"
      "os"
      "host"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "display"
      "de"
      "wm"
      "wmtheme"
      "theme"
      "icons"
      "font"
      "cursor"
      "terminal"
      "terminalfont"
      "cpu"
      "gpu"
      "memory"
      "swap"
      "disk"
      "battery"
      "poweradapter"
      "locale"
      "break"
      "colors"
    ];
  };

  options.package.defaultFunc = {inputs}:
    inputs.nixpkgs.pkgs.fastfetch.minimal.override {
      audioSupport = true;
      brightnessSupport = true;
      codecSupport = true;
      dbusSupport = true;
      imageSupport = true;
      openclSupport = true;
      openglSupport = true;
      sqliteSupport = true;
      terminalSupport = true;
      vulkanSupport = true;
      waylandSupport = true;
    };
}
