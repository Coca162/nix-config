{promise, ...}: {
  inputs = {
    config.from = {parent}: parent.config;
  };

  options.settings.default = {
    theme_background = false;
    rounded_corners = false;
    clock_format = "%a %d %b %m %X";

    # zswap PR needs these to look nice atm
    mem_graphs = false;
    swap_disk = false;
  };

  options.package.default =
    promise ({inputs}: let
        pkgs = inputs.nixpkgs.pkgs;
      in
        (pkgs.btop.override {
          cudaSupport = inputs.config.nvidia;
        })
  .overrideAttrs {
          patches = [
            # from https://github.com/NotAShelf/nyxexprs, EUPLv1.2
            ./normalize_processes.patch
            # https://github.com/aristocratos/btop/pull/1739
            ./zswap.patch
          ];
          # cmakeBuildType = "Debug";
        });
}
