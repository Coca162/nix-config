_: {
  inputs = {
    config.from = {parent}: parent.config;
  };

  options.settings.default.theme_background = false;
  options.package.defaultFunc = {inputs}:
    inputs.nixpkgs.pkgs.btop.override {
      cudaSupport = inputs.config.nvidia;
    };
}
