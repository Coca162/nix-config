{promise, ...}: {
  options.configFiles.default = [(builtins.toString ./config.kdl)];

  options.package.default = promise ({inputs}: let
    pkgs = inputs.nixpkgs.pkgs;
  in
    pkgs.niri.overrideAttrs (finalAttrs: _: {
      src = pkgs.fetchFromGitHub {
        owner = "niri-wm";
        repo = "niri";
        rev = "eb072e029a5b497c264c8d11a327bb4bcad85c48";
        hash = "sha256-z/jsUe7O6diShp7lVtxKZqc1XN8ARTEEqlmZy9Ry7Qs=";
      };

      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) src patches;
        hash = "sha256-J8U0ebNguESGVOZF5qIKG53+zmc65b7UP3djq/ZjL48=";
      };
    }));
}
