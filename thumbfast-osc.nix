pkgs:
pkgs.mpvScripts.buildLua {
  pname = "mpv-thumbfast-osc";
  version = "unstable-2023-06-04";

  src = pkgs.fetchFromGitHub {
    owner = "po5";
    repo = "thumbfast";
    rev = "5fefc9b8e995cf5e663666aa10649af799e60186";
    hash = "sha256-6nICOdtPzDQUMufqCJ+g2OnPasOgp3PegnRoWw8TVBU=";
  };

  scriptPath = "player/lua/osc.lua";
}
