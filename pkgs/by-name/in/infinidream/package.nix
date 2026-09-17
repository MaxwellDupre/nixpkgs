{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gitMinimal,
  shaderc,
  wayland-scanner,
  boost,
  curl,
  ffmpeg-headless,
  libpng,
  openssl,
  libx11,
  libxrender,
  libdecor,
  libxkbcommon,
  wayland,
  wayland-protocols,
  vulkan-headers,
  vulkan-loader,
}:

let
  imguiSrc = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "6ded5230d043aa32c755e65c910c2af5002fb9f9";
    hash = "sha256-k/cHYs/qjt6MGJUFE+74UqOGRTDlEe8p3oATQdVcQOA=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "infinidream";
  version = "0.16.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "e-dream-ai";
    repo = "client";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-sMnin5FDGFQy2YxMigE1RXkuCsEQYiF9g5b8zwJJ0h0=";
  };

  sourceRoot = "${finalAttrs.src.name}/client_generic/LinuxBuild";

  postPatch = ''
    chmod u+w ../imgui
    cp -r ${imguiSrc}/. ../imgui/
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    gitMinimal
    shaderc
    wayland-scanner
  ];

  buildInputs = [
    boost
    curl
    ffmpeg-headless
    libpng
    openssl

    libx11
    libxrender

    libdecor
    libxkbcommon
    wayland
    wayland-protocols
    vulkan-headers
    vulkan-loader
  ];

  cmakeFlags = [
    "-DAPP_VERSION=${finalAttrs.version}"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 infinidream "$out/bin/infinidream"

    if [ -d shaders ]; then
      cp -r shaders "$out/bin/shaders"
    fi

    if [ -f BuildData.json ]; then
      install -Dm644 BuildData.json "$out/bin/BuildData.json"
    fi

    substituteInPlace ../infinidream.desktop \
      --replace-fail \
        "Exec=infinidream" \
        "Exec=$out/bin/infinidream"

    install -Dm644 \
      ../infinidream.desktop \
      "$out/share/applications/infinidream.desktop"

    runHook postInstall
  '';

  meta = {
    description = "Generative visual screensaver, originally Electric Sheep";
    homepage = "https://infinidream.ai/";
    changelog = "https://github.com/e-dream-ai/client/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    mainProgram = "infinidream";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      mikecm
    ];
  };
})
