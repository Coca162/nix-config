{
  pkgs,
  lib,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.tools.nixos-option.enable = false; # Complains about Lix or something

  boot.supportedFilesystems = ["ntfs"];
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "vm.swappiness" = 5;
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "bg_BG.UTF-8"; # Imperial metrics?! Couldn't be me.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.coca = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.coca = lib.mkDefault (import ./home.nix);

  environment.systemPackages = with pkgs; [
    wl-clipboard-rs
    nvd
    nix-output-monitor
    lsof
    fatrace
    waypipe
    sshfs
    btrfs-progs
  ];

  programs.fish.enable = true;
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;
  environment.variables.MANPAGER = "${lib.getExe pkgs.bat} --wrap=auto --language=man --plain --strip-ansi=auto";

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      aliases.url = {
        "https://codeberg.org/".insteadOf = ["cb:" "codeberg:"];
        "https://github.com/".insteadOf = ["gh:" "github:"];
        "https://gitlab.com/".insteadOf = ["gl:" "gitlab:"];
        "https://git.lix.systems/".insteadOf = "lix:";
        "https://git.coca.codes/".insteadOf = "coca:";
      };
    };
  };

  programs.ssh.package = pkgs.openssh_hpn;

  nixpkgs.config.allowUnfree = true;

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  ''; # Keeps the compiled build outputs, means we don't have to rebuild everything again after gc

  system.rebuild.enableNg = true;
}
