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
            (pkgs.fetchpatch {
              url = "https://github.com/aristocratos/btop/pull/1739.patch";
              hash = "sha256-Cxq4MdXGnNFIHI8EXnJufSWA8PgM0b9GZa/NRMQPdak=";
            })
          ];
          # cmakeBuildType = "Debug";
        });
}
