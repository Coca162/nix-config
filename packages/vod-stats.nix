{
  writers,
  fetchgit,
}: let
  repo = fetchgit {
    url = "https://gist.github.com/Coca162/5b2326fd95de9493fee48d579caf5696";
    rev = "7f6e90d8d2559f2b73470e82a5b17e188a4a7dae";
    hash = "sha256-DOKl74Ko3QFfx0Cb4V0j0r2KhUV+y8PZSVc7iJ25Kyg=";
  };
in
  writers.writeNuBin "vod-stats" (builtins.readFile "${repo}/vod-stats.nu")
