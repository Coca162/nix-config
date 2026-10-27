{
  mkKdeDerivation,
  fetchFromGitLab,
  dragon-media-backend,
}:
mkKdeDerivation {
  pname = "elisa";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "multimedia";
    repo = "elisa";
    rev = "778a7c79029be0e6d863673ca76975512396af9c";
    hash = "sha256-PKJY5YnpWrmFXJOStt2X3wIXJEME3MbBxI+8x+xZ/xw=";
  };

  extraBuildInputs = [dragon-media-backend];
  meta.mainProgram = "elisa";
}
