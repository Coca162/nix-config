{
  config,
  pkgs,
  lib,
  nix-minecraft ? null,
  ...
}:
if nix-minecraft != null
then {
  imports = [nix-minecraft.nixosModules.minecraft-servers];

  nixpkgs.overlays = [nix-minecraft.overlay];

  environment.systemPackages = with pkgs; [mcrcon];

  services.minecraft-servers = {
    enable = true;
    eula = true;
  };

  services.minecraft-servers.servers.cool-modpack = {
    enable = true;
    package = pkgs.fabricServers.fabric;
    openFirewall = true;
    serverProperties = {
      enable-rcon = true;
      "rcon.password" = "longview";
    };
    symlinks = {
      mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
        Lithium = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/nMhjKWVE/lithium-fabric-mc1.20.4-0.12.1.jar";
          sha512 = "70bea154eaafb2e4b5cb755cdb12c55d50f9296ab4c2855399da548f72d6d24c0a9f77e3da2b2ea5f47fa91d1258df4d08c6c6f24a25da887ed71cea93502508";
        };
      });
    };
  };
}
else {}
