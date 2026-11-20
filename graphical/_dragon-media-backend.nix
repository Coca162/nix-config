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
  gitUpdater,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dragon-media-backend";
  version = "0.90.1";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "libraries";
    repo = "dragon-media-backend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V//h2YnTZSzNtgTyJu2+IWlvB30dPA0Ar3A5jBcNDIY=";
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
  strictDeps = true;
  __structuredAttrs = true;

  passthru.updateScript = gitUpdater {rev-prefix = "v";};

  meta = {
    description = "Qt C++ library intended for desktop music players";
    homepage = "https://invent.kde.org/libraries/dragon-media-backend";
    donationPage = "https://kde.org/donate/";
    platforms = lib.platforms.linux;
    maintainers = [lib.maintainers.coca];
    # Licenses referenced from pkgs/kde/lib/mk-kde-derivation.nix and reuse lint
    license = with lib.licenses; [
      bsd3
      cc-by-40
      cc-by-sa-40
      cc0
      lgpl21Only
      lgpl3Only
      lgpl3Plus
      mit
      zlib
    ];
  };
})
