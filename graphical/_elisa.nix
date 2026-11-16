{
  mkKdeDerivation,
  fetchFromGitLab,
  dragon-media-backend,
}: let
  version = "26.11.80";
in
  mkKdeDerivation {
    pname = "elisa";
    inherit version;

    src = fetchFromGitLab {
      domain = "invent.kde.org";
      owner = "multimedia";
      repo = "elisa";
      tag = "v${version}";
      hash = "sha256-p1ka+y6Zb82uIqiEVc3CJLIER/YgjQhzwF8+NcE/urg=";
    };

    extraBuildInputs = [dragon-media-backend];
    meta.mainProgram = "elisa";
  }
