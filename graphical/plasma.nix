{
  pkgs,
  lib,
  ...
}: {
  specialisation.plasma.configuration = {
    programs = {
      gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
      ssh.enableAskPassword = true;
      ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    };
    environment.variables.SSH_ASKPASS_REQUIRE = "prefer";
    services = {
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };
    environment.systemPackages = [pkgs.spawn-terminal];
    # Default for plasma, turn on tlp instead if wanted
    services.power-profiles-daemon.enable = lib.mkForce false;
  };
}
