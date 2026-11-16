{pkgs, ...}: {
  services.bootvine.enable = true;

  services.bootvine.package = pkgs.bootvine.overrideAttrs (finalAttrs: _: {
    version = "0.1.4";

    src = pkgs.fetchFromCodeberg {
      owner = "wvhulle";
      repo = "bootvine";
      tag = "v${finalAttrs.version}";
      hash = "sha256-47+MgKwFUErTiop+xab4F4AY0HqOZHCZy/OSoUo5Eqs=";
    };

    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src patches;
      hash = "sha256-yUq+gUSFaDNlkEv8nEpKYFYMTSelunTEfQHnvFt1osY=";
    };
  });
}
