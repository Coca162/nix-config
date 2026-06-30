{baseVars, ...}: {
  services.greetd = {
    enable = true;
    restart = false;
    useTextGreeter = true;
  };

  services.greetd.settings = {
    default_session = {
      command = "agreety --cmd $SHELL";
    };
    initial_session = {
      command = "$SHELL";
      user = baseVars.username;
    };
  };
}
