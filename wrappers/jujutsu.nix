_: {
  options.settings.default = {
    user = {
      name = "Coca";
      email = "me@coca.codes";
    };
    signing = {
      behaviour = "drop";
      backend = "gpg";
      key = "0x03282DF88179AB19";
    };
    git.sign-on-push = true;
  };
}
