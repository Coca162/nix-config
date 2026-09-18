_: {
  options.settings.default = {
    user = {
      name = "Coca";
      email = "me@coca.codes";
      signingKey = "0x03282DF88179AB19";
    };

    init.defaultBranch = "main";

    commit.gpgSign = true;
    tag.gpgSign = true;

    # Watched https://youtu.be/aolI_Rz0ZqY
    rerere.enabled = true;
    column.ui = "auto";
    branch.sort = "-committerdate";
  };

  mutations = {
    "/fish".abbreviations = _: {
      gpf = "git push --force-with-lease";
    };
  };
}
