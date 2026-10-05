_: {
  options.flags.default = ["-a"];

  mutations = {
    "/fish".abbreviations = rec {
      ls = "eza";
      lsa = "eza -mbhlU --icons auto";
      tree = "eza --tree -mbhlu --icons auto";
      dirs = "eza --only-dirs";
      dir = dirs;
    };
  };
}
