_: {
  inputs = {
    config.from = {parent}: parent.config;
  };

  options.settings.default = {
    theme_background = false;
    rounded_corners = false;

    # # crappy zswap PR needs these to look nice
    # mem_graphs = false;
    # swap_disk = false;
  };

  options.package.defaultFunc = {inputs}: let
    pkgs = inputs.nixpkgs.pkgs;
  in (pkgs.btop.override {
    cudaSupport = inputs.config.nvidia;
  });
  # .overrideAttrs {
  #     src = pkgs.fetchFromGitHub {
  #       repo = "btop";

  #       #   owner = "aristocratos";
  #       #   rev = "34831e7095f83f4d4de4693377a03a7493aae7e8";
  #       #   hash = "sha256-Wpdw+2rbs4sFjHiWw9r4H80+R14sqFczT3wSV5xmzts=";

  #       owner = "tepo4ka";
  #       # Works
  #       # rev = "32119293ab654a2a4ca9b2bd43b32947a9f3bba8";
  #       # hash = "sha256-78Ag1VKuBFEEb+1KtakGbmtMoJ2aD5sBAzUNjwpNUdM=";

  #       rev = "6a3a3382f7999a90f7c271dcdf9be8f10a7ca2b2";
  #       hash = "sha256-qb21hyL0tUm4SKOpV0XmbnsF8ycBJGQlNnucivSfZZc=";
  #     };
  #     # patches = [./btop.patch];
  #     # cmakeBuildType = "Debug";
  #   };
}
