{
  stdenv,
  lib,
  fetchFromGitLab,
  cmake,
  pkg-config,
  kdePackages,
  ffmpeg,
  sdl3,
  kissfft,
  kissfftFloat,
  libcdio,
  pipewire,
  libpulseaudio,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dragon-media-backend";
  version = "0.83.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "libraries";
    repo = "dragon-media-backend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F0uIjNJtDAbAaKfFfdZMc66zlS+PiZVVl4Bn2poGlJI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    kdePackages.extra-cmake-modules
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.kio
    ffmpeg
    kdePackages.qcoro
    sdl3
    kissfft
    kissfftFloat
    kdePackages.libkcddb
    libcdio
    pipewire
    libpulseaudio
  ];

  dontWrapQtApps = true;

  meta = {
    maintainers = [lib.maintainers.coca];
    platforms = with lib.platforms; linux;
  };
})
