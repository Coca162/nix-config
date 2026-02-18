{
  pkgs,
  baseVars,
  ...
}: {
  users.users.${baseVars.username} = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.fish;
  };
}
