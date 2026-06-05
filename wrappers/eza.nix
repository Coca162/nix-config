_: {
  options.flags.default = ["-a"];

  mutations = {
    "/fish".abbreviations = _: rec {
      ls = "eza";
      lsa = "eza -mbhlU --icons";
      tree = "eza --tree -mbhlu --icons";
      dirs = "eza --only-dirs";
      dir = dirs;
    };
  };
}
