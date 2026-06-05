{
  baseVars,
  wrappers,
  ...
}: {
  users.users.${baseVars.username} = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = wrappers.fish;
  };
}
