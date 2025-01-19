{
  lib,
  stdenv,
  fetchFromGitHub,
  postgresql_16,
  python3Minimal,
}:
stdenv.mkDerivation rec {
  pname = "pguint";
  version = "1.20231206";

  makeFlags = ["PYTHON=${python3Minimal}/bin/python"];

  buildInputs = [postgresql_16];

  src = fetchFromGitHub {
    owner = "petere";
    repo = pname;
    rev = version;
    hash = "sha256-BhLdepG8ozuGw8nURuIKPIYUCF9k+UJUAl7xsWBIvCU=";
  };

  installPhase = ''
    install -D -t $out/lib uint${postgresql_16.dlSuffix}
    install -D -t $out/share/postgresql/extension *.sql
    install -D -t $out/share/postgresql/extension uint.control
  '';

  meta = with lib; {
    description = "Unsigned integer types extension for PostgreSQL";
    homepage = "https://github.com/petere/pguint";
    changelog = "https://github.com/petere/pguint/releases/tag/${version}";
    maintainers = with maintainers; [coca];
    platforms = postgresql_16.meta.platforms;
    license = licenses.postgresql;
  };
}
